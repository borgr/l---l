	NotPhrase = ["punctuation", "symbol", "number"]
	def get_document
		#d = document "http://en.wikipedia.org/wiki/Olfactory_bulb"
		#return d.apply(:chunk,:segment,:tokenize,:tag)
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
	###################should add ignore
	def phrase_start_with? (phrase, sensitive, *words)
		#check for longest words, no need to downcase all the long phrase.
		length = 0
		words.each do |word|
			if word.length > length
				length = word.length
			end
		end
		phrase_string = phrase.to_s[0, length]
		if !sensitive
			phrase_string.downcase!
			words.each do |word|
				word.downcase!
			end
		end

		return words.any? {|word| phrase_string.start_with? (word)}
	end
