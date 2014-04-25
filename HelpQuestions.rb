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
	# ignore - a list of words to ignore
	def phrase_start_with? (phrase, sensitive, ignore, *words)
		#check for longest words, no need to downcase all the long phrase.
		length = 0
		
		# there must be a better way to do it like in python max(words+ignore, lambda x: x.length) 
		##########################################################################################
		words.each do |word|
			if word.length > length
				length = word.length
			end
		end
		ignore.each do |word|
			if word.length > length
				length = word.length
			end
		end
		##########################################################################################

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

		
	def remove_ads_recursivly(phrase, start = true, string)
		check_punctuation = false
		punctuation_before =
		phrase.each do |sub|
			if check_punctuation && sub.is_a? Treat::Entities::Punctuation # if it is a panctuation remove HESGER
				string.slice! last_phr.to_s
			end
			
			# if it is an ADJP or ADVP after a punctuation, check if the next thing is a punctuation
			if punctuation_before && (sub.tag == "ADVP" || sub.tag == "ADJP") 
				check_punctuation = true
				last_phr = sub.to_s
			else 
				check_punctuation = false
			end

			
			# check if next run will have the potential of being an HESGER
			if sub.is_a? punctuation
				punctuation_before = true
			else
				punctuation_before = false
			end

			# do the same for sub entities
			string = remove_ads_recursivly(sub, check_punctuation, string)
		end
		return string
	end

	# need to check if it works!!!!! and then delete this part############################################################
	require 'treat'
	include Treat::Core::DSL
	d = section 'In humans, however, the olfactory bulb is on the inferior (bottom) side of the brain.'
	d.apply(:chunk,:segment,:tokenize,:parse)
	puts remove_ads(d)
	###############################################################################################################

	# takes a sentence and removes unimportant parts (X ,y and Z -> X , HESGER), returns a string
	# important - an array of strings. when removing duplicants, chooses the important ones if they exist.
	def compact_sentence (sentence, important)
		###############unimplemented, choosing important may work like remove_ads (go each level recursivly, and remove if necessary)
		remove_ads(sentence)
	end
