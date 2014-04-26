NotPhrase = ["punctuation", "symbol", "number"]
	def get_document
		#d = document "http://en.wikipedia.org/wiki/Olfactory_bulb"
		#return d.apply(:chunk,:segment,:tokenize,:parse)
		return document 'processed_doc.xml' 
	end

	# checks if the string is in the array or is part of the array's strings
	# exact - if true returns only if the full string is in the array
	# note that the check is case sensitive
	def in_arr? (arr, text, exact)
		if exact
			return arr.include? text
		else
			return arr.any?{|s| s.include? text}
		end
	end

	# a function that checks if one of the sections in the phrase has one of the tags
	# the function ignores matches that are in the ignore array
	# phrase - any section
	# tags - an array of strings containing POS tag names
	# ignore - an array with strings to ignore
	# insensitive - boolean case insensitive or not. default is true.
	# exact - check for exact match with the ignore
	def tagged (phrase, tags, ignore = [], insensitive = true, exact = true)
		# make sure insensitive
		if insensitive
			ignore = ignore.map(&:downcase)
		end
		# p.o.s. are always upcase, just to make sure
		tags = tags.map(&:upcase)
		phrase.each_entity do |sub|
			if tags.include? sub.tag
				if insensitive
					if !in_arr?(ignore, sub.to_s.downcase, exact)
						return sub
					end
				elsif !in_arr?(ignore, sub, exact)
						return sub
				end
			end
		end
		return nil
	end

	# checks if this entity is of the right tag
	# tags - an array of strings to check if matches or not.
	def exact_tag(entity, tags)
		return (entity.has? :tag )&&( in_arr?(tags, entity.tag, true))
	end

	#makes sure the phrase is proper
	def properPhrase (phrase)
		if !in_arr?(NotPhrase, phrase.type.to_s, false)
			return phrase.words.any?{|word| word.tag != "CD"}
		else
			return false
		end
	end

	#checks if the phrase starts with one of the givven words
	# words - an array of strings
	# sensitive - if true checks case sensitive
	# ignore - an array of strings to ignore
	def phrase_start_with? (phrase, sensitive, ignore, *words)
		#check for longest words, no need to downcase all the long phrase.
		length = 0
		(words + ignore).max {|w,v| w.length <=> v.length}
		phrase_string = phrase.to_s[0, length]
		if !sensitive
			phrase_string.downcase!
			words.each do |word|
				word.downcase!
			end
		end

		return words.any? {|word| phrase_string.start_with? (word)} && !ignore.any? {|word| phrase_string.start_with? (word)}
	end

#######################################need to debug!! is_a in wrong syntax twice####################################################################################
	# This function gets a phrase and returns a string of the phrase without any HESGER
	# phrase - an entity to check (preferable not tokens)
	# start - a boolean representing if this is the beggining of a phrase or comes
	# after a punctuation
	# sentence - true if this is a sentence and not just a phrae
	def remove_ads(phrase, sentence = true, start = true)
		res = remove_ads_recursivly(phrase, start, phrase.to_s)
		if sentence
			res.capitalize!
		end
		return res
	end

	# This function goes through each level of the phrase and removes HESGER from it
	# 
	def remove_ads_recursivly(phrase, start = true, string)
		check_punctuation = false
		first_punctuation = nil
		punctuation_before = start
		tags = ["ADVP"]
		last_phr = nil #the variable should never be used before a real string is assigned to it
		phrase.each do |sub|
			if check_punctuation && sub.is_a?(Treat::Entities::Punctuation) # if it is a panctuation remove HESGER
				puts "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiin"+phrase
				puts "sssssssssssssssssssssssssssssssssssssssssssssssstring " + phrase.to_s
				string.gsub!(/\s* #{Regexp.escape(first_punctuation)}* \s* #{Regexp.escape(last_phr)} \s* #{Regexp.escape(sub.to_s)} \s*/x, " ")
				puts "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaastring after " + last_phr
				check_punctuation = false
				punctuation_before = true
				first_punctuation = sub.to_s
			else
				# if it is an ADJP or ADVP after a punctuation, check if the next thing is a punctuation
				if punctuation_before && exact_tag(sub, tags)
					check_punctuation = true
					last_phr = sub.to_s
				# check if next run will have the potential of being an HESGER
				elsif sub.is_a?(Treat::Entities::Punctuation)
					punctuation_before = true
					first_punctuation = sub.to_s
				else 
				# This sub is neither a punctuation nor a potential HESGER
					check_punctuation = false
					punctuation_before = false
				end
			end

			# do the same for sub entities
			string = remove_ads_recursivly(sub, check_punctuation, string)
		end

		#if it ends with it, and without a punctuation, it must be an HESGER at the end.
		if check_punctuation
			string.gsub!(/\s* #{Regexp.escape(first_punctuation)}* \s* #{Regexp.escape(last_phr)} \s* /x, " ")
			
		end
		return string
	end

	# # need to check if it works!!!!! and then delete this part############################################################
	# require 'treat'
	# include Treat::Core::DSL
	# # d = section 'In humans, however, the olfactory bulb is on the inferior (bottom) side of the brain.'
	# # d.apply(:chunk,:segment,:tokenize,:parse)
	# d = get_document
	# # puts d.visualize
	# remove_ads(d)
	###############################################################################################################

	# takes a sentence and removes unimportant parts (X ,y and Z -> X , HESGER), returns a string
	# important - an array of strings. when removing duplicants, chooses the important ones if they exist.
	def compact_sentence (sentence, important)
		###############unimplemented, choosing important may work like remove_ads (go each level recursivly, and remove if necessary)
		remove_ads(sentence)
	end
