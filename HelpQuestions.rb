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

# checks if any of the strings in the array is in the string
def arr_in_phrase? (arr, string)
	#might be unefficient to recreate the reg each time, maybe better to return a regex?
	reg = arr.map {|str| Regexp.escape(str)}
	reg = /#{arr.join("|")}/ 
	return reg === string
end

# a function that checks if one of the sections in the phrase has one of the tags
# the function ignores matches that are in the ignore array
# phrase - any section
# tags - an array of strings containing POS tag names
# ignore - an array with strings to ignore
# insensitive - boolean case insensitive or not. default is true.
# exact - check for exact match with the ignore
#
# return - the entity that was tagged or nil if there isn't one
def tagged (phrase, tags, ignore = [], insensitive = true, exact = true)
	# make sure insensitive
	if insensitive
		ignore = ignore.map(&:downcase)
	end
	# p.o.s. are always upcase, just to make sure
	tags = correct_tags(tags) #what was the ruby way to call a functioin in place? !
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

# a function that corrects the tags a function has got
def correct_tags(tags)
	return tags.map(&:upcase)
end

# checks if this entity is of the right tag
# tags - an array of strings to check if matches or not.
def exact_tag?(entity, tags)
	return (entity.has? :tag )&&( in_arr?(tags, entity.tag, true))
end

# makes sure the phrase is proper
def properPhrase? (phrase)
	if !in_arr?(NotPhrase, phrase.type.to_s, false)
		return phrase.words.any?{|word| word.tag != "CD"}
	else
		return false
	end
end

#checks if the phrase starts with one of the givven words
# phrase - a Treat object
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

	# check if this works. nicer syntax :)
	# return words.reject{|w| ignore.include? w}.any? {|w| phrase_string.start_with? w}

end

# If change is true, changes the phrase into a sentence
# text - a string that may need to become a sentence.
def sentencize (text, change)

	return change ? text.capitalize! : text

end

# This function gets a phrase and returns a string of the phrase without any interrupting phrase
# phrase - an entity to check (preferable not tokens)
# start - a boolean representing if this is the beggining of a phrase or comes
# after a punctuation
# sentence - true if this is a sentence and not just a phrae
def remove_interrupts(phrase, sentence = true, start = true)
	res = remove_interrupts_recursivly(phrase, start, phrase.to_s)
	return sentencize(res, sentence)
end

# This function goes through each level of the phrase and removes interrupting phrase from it
# 
def remove_interrupts_recursivly(phrase, start = true, string)
	check_punctuation = false
	first_punctuation = nil
	punctuation_before = start
	tags = ["ADVP"]
	last_phr = nil #the variable should never be used before a real string is assigned to it
	phrase.each do |sub|
		if check_punctuation && sub.is_a?(Treat::Entities::Punctuation) # if it is a panctuation remove interrupting phrase
			string.gsub!(/\s* #{Regexp.escape(first_punctuation)}* \s* #{Regexp.escape(last_phr)} \s* #{Regexp.escape(sub.to_s)} \s*/x, " ")
			check_punctuation = false
			punctuation_before = true
			first_punctuation = sub.to_s
		else
			# if it is an ADJP or ADVP after a punctuation, check if the next thing is a punctuation
			if punctuation_before && exact_tag?(sub, tags)
				check_punctuation = true
				last_phr = sub.to_s
			# check if next run will have the potential of being an interrupting phrase
			elsif sub.is_a?(Treat::Entities::Punctuation)
				punctuation_before = true
				first_punctuation = sub.to_s
			else 
			# This sub is neither a punctuation nor a potential interrupting phrase
				check_punctuation = false
				punctuation_before = false
			end
		end

		# do the same for sub entities
		string = remove_interrupts_recursivly(sub, check_punctuation, string)
	end

	#if it ends with it, and without a punctuation, it must be an interrupting phrase at the end.
	if check_punctuation
		string.gsub!(/\s* #{Regexp.escape(first_punctuation)}* \s* #{Regexp.escape(last_phr)} \s* /x, " ")
		
	end
	return string
end

# removes text with the same position in the phrase (a beautiful and merciful > a beautiful)
# an entity 
# important - an array of strings phrases containing strings in important will not be removed
def remove_duplicates(phrase, important, sentence = true)
	res = remove_duplicates_recursivly(sentence, important, sentence.to_s)
	return sentencize(res, sentence)
end

# a recursive helper for remove_duplicates
# string - the string we are working at
# important - an array of strings phrases containing strings in important will not be removed
# phrase
def remove_duplicates_recursivly (phrase, important, string)
	type = [""]
	removables = ["CC", ","]
	phrase.each do |sub|
		if sub.exact_tag?(type)
			# it is a repetition
			if delete.empty?
			# If it is the first repetition, check the first
			# done to avoid checking every entity if in important
				delete[!arr_in_phrase(important, sub.to_s)]
			end
			# save it
			same << sub.to_s
			delete << !arr_in_phrase(important, sub.to_s)

		elsif sub.exact_tag?(removables)
			# it is not a repetition, but it is a connector of some sort ("," "or" "and" maybe something else?)
			to_remove = sub.to_s
		elsif !sub.exact_tag?(removables)
			# not a repetition
			if !same.empty? && delete.any?{|boolean|boolean}
				# delete unnecessary information
				# need to implement: sub! every true and its left removable (from to_remove) and spaces by a space
				# if there is only one true, delete all removables
				# elsif the last one is false put its left removable (from to_remove)
				# before the last undeleted string, and delete the other removable so there wont be 2 of them. (example: one, two and three -> delete three -> one and two)
			end
			same = [sub.to_s]
			delete = []
			if sub.has? :tag
				type = sub.tag
			end
		end
		string = remove_duplicates_recursivly(sub, important, string)
	end
end

# require 'treat'
# include Treat::Core::DSL
# # d = section 'In humans, however, the olfactory bulb is on the inferior (bottom) side of the brain.'
# # d.apply(:chunk,:segment,:tokenize,:parse)
# d = get_document
# # puts d.visualize
# remove_interrupts(d)
###############################################################################################################

# takes a sentence and removes unimportant parts (X ,y and Z -> X , interrupting phrase), returns a string
# important - an array of strings. when removing duplicants, chooses the important ones if they exist.
def compact_sentence (sentence, important)
	remove_interrupts(sentence)
	remove_duplicates(sentence, important)
end
