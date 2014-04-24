
	def get_document
		#d = document "http://en.wikipedia.org/wiki/Olfactory_bulb"
		#return d.apply(:chunk,:segment,:tokenize,:tag)
		return document 'processed_doc.xml' 
	end

	# checks if the string is in the array or is part of the array's strings
	# exact - if true returns only if the full string is in the array
	# note that the check is case sensitive
	def in_arr? (arr, text, exact)

	# ###how come these question is being made? what is the bug?
	# *****************
	# question62: what are associated with behavioral changes characteristic of depression, demonstrating the correlation between the olfactory bulb and emotion? ---
	# answer: These hippocampal changes due to olfactory bulb removal

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
	# exact - check for exact match
	def tagged (phrase, tags, ignore = [], insensitive = true, exact = true)
		# make sure insensitive
		if insensitive
			ignore = ignore.map(&:downcase)
		end
		# pos are always upcase, just to maek sure
		tags = tags.map(&:upcase)

		phrase.each do |sub|
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
		return phrase.words.any?{|word| word.tag != "CD"}
	end
