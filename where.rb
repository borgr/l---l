require 'treat'

include Treat::Core::DSL

require_relative 'HelpQuestions'

par = get_document
#ask where ************
#answer noun ************
counter = 0;
par.each_sentence do |sent|
	adj, noun = nil,nil
	#need to check which sentences contain PP with the word in at the begginning
	#then to see if they are not in time or something. 
	prepositional = tagged(sent, ["PP"])
	if phrase_start_with?(prepositional, false, ["in time", "in particular"], "in ") 
	##########currently finding good sentences, probably ignore list should be bigger.
	######## need to make it ask "where does compact_sentence without PP" and answer is PP
			putsputs prepositional
	end
end

#################not working, need to find sentences that contain a PP phrase that starts with in
