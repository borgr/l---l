require 'treat'

include Treat::Core::DSL

require_relative 'HelpQuestions'
IN_IGNORE_LIST = ["in time", "in particular"]
par = get_document
#ask where ************
#answer noun ************
counter = 0;
par.each_sentence do |sent|
	adj, noun = nil,nil
	#need to check which sentences contain PP with the word in at the begginning
	#then to see if they are not in time or something. 
	prepositional = tagged(sent, ["PP"])

	if phrase_start_with?(prepositional, false, IN_IGNORE_LIST , "in ") 
		counter += 1
		result = sent.to_s
		result.slice! prepositional.to_s
		puts "question#{counter}: where does " + result + "?---"
		puts "answer: #{prepositional}"
		puts "*****************"
	
	end
end

=begin
problems: 
double space or , remains
. at end of sentence remains, should make a general question-answer making function (that also removes what is needed)
some questions sound better starting with "in what" instead of "where"

	bad questions found

end
