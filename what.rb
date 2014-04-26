require 'treat'

include Treat::Core::DSL

require_relative 'HelpQuestions'
#d = document "http://en.wikipedia.org/wiki/Olfactory_bulb"

#d.apply(:chunk,:segment,:tokenize,:tag)

par = get_document

#a constant list of prepositions that should not be in the verb phrase
NoWhat = ['into']


#ask what verb
#answer noun phrase before the verb
counter = 0;
par.each_sentence do |sent|
	verb,noun = nil,nil
	sent.each do |phrase|
		if properPhrase(phrase)
			if phrase.tag == "VP" 
				#check if this is not a special case of VP
				if !(arr_in_phrase?(NoWhat, phrase.to_s)) && 
					verb = phrase
				else
					#need to implement or use another loop
				end

			 #english is usually svo -> subject verb object 
			 #so if a name phrase is before the verb it will be probably the subject
			elsif phrase.tag == "NP" && verb == nil
				check_tags = tagged(phrase, ["DT","PRP", "EX"], ["the", "a"])
				# puts check_tags.to_s
				if !check_tags
					noun = phrase
				end
			end
			if verb != noun && verb != nil && noun != nil
				counter += 1
				puts "question#{counter}: what #{verb}? ---"
				puts "answer: #{noun}"
				puts "*****************"
			end
		end
	end
end
