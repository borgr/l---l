require 'treat'
include Treat::Core::DSL

require_relative 'HelpQuestions'
par = get_document


#create a blank over a number
=begin 
still quite naive.
should enhancing it with names and places be smart, or should they be different functions?
=end

par.each_sentence do |sent|
	number = tagged(sent, ["QP", "CD"], [], true, false )
	if number
		question = sent.to_s.sub(number, "_____")
		puts "Fill the blank: #{question}"
		puts "Answer: #{number}"
		puts "**************************************"
	end
end
