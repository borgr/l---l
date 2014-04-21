
require 'treat'

include Treat::Core::DSL

#d = document "http://en.wikipedia.org/wiki/Olfactory_bulb"

#d.apply(:chunk,:segment,:tokenize,:tag)

par = document 'processed_doc.xml'

#a constant list of prepositions that should not be in the verb phrase
NoWhat = ['into']
RegNoWhat = /#{NoWhat.join("|")}/ # assuming there are no special chars

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
# exact - check for exact match
def tagged (phrase, tags, ignore, insensitive = true, exact = true)
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

#ask what verb
#answer noun phrase before the verb
counter = 0;
par.each_sentence do |sent|
	verb,noun = nil,nil
	sent.each do |phrase|
		if phrase.tag == "VP" 
			#check if this is not a special case of VP
			if !(RegNoWhat === phrase.to_s)
				verb = phrase
			else
				#need to implement or use another loop
			end

		 #english is usually svo -> subject verb object 
		 #so if a name phrase is before the verb it will be probably the subject
		elsif phrase.tag == "NP" && verb == nil
			check_tags = tagged(phrase, ["DT","PRP"], ["the", "a"])
			# puts check_tags.to_s
			if !check_tags
				noun = phrase
			end
		end
	end
	if verb != noun && verb != nil && noun != nil
		counter += 1
		puts "question#{counter}: what #{verb}? ---"
		puts "answer: #{noun}"
		puts "*****************"
	end

end

