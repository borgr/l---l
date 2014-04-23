# a script for doc getting.
# takes a url and filename, download doc from url and create serialized object
# at filename.

require 'logger'
require 'treat'

include Treat::Core::DSL

logger = Logger.new(STDERR)
logger.level = Logger::INFO

logger.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime}]:\t#{severity}\t#{msg}\n"
end


if ARGV.length != 2
	logger.error "missing or too many parameters... exiting"
	logger.info "USAGE: ruby getdoc.rb url filename"
	exit
end

url, file = ARGV

logger.info "loading document from #{url}"
doc = document url
logger.info "done"

logger.info "start processing doc"
doc.apply(:chunk,:segment,:tokenize,:tag)
logger.info "done"

logger.info "start parsing doc"
begin
	doc.apply(:parse)
rescue Exception => e
	logger.error "exception at parsing - #{e.message}"
	logger.debug "#{e.backtrace.inspect}"
end
logger.info "done"

logger.info "saving serialized doc to #{file}"
doc.serialize :xml, file: file
logger.info "done"
