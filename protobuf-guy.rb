#!/usr/bin/env ruby 

# == Synopsis 
#   Simple command line tool to translate protobuf messages into code.
#   The tool should work platform independed.
#
# == Examples
#   This command does blah blah blah.
#     protobuf-guy -i tests -o tests
#
# == Usage 
#   protobuf-guy [options]
#
#   For help use: protobuf-guy -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -V, --verbose       Output as much as possible
#
# == Author
#   Christian Blank <christian.blank@haw-hamburg.de>

require 'optparse' 
require 'ostruct'
require 'date'
require 'rbconfig'
require 'pathname'
require 'csv'
require 'fileutils'
require './src/guy'

class App
  VERSION = '0.2.1'
  
  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin
    
    # Set defaults
    @options = OpenStruct.new
    @opts
  end

  # Parse options, check arguments, then process the command
  def run
    if parsed_options? && arguments_valid? 
      puts "Start at #{DateTime.now}" if @options.verbose
      output_options if @options.verbose # [Optional]
      process_arguments
      # add parameters
      args = {}
      # TODO: use correct syntax for set
      args[:verbose] = @options.verbose if @options.verbose
      args[:input] = @options.input if @options.input
      args[:output] = @options.output if @options.output
      args[:map_name] = @options.map_name if @options.map_name
      args[:not_installed] = @options.cwd if @options.cwd
      
      program = Guy.new args
      program.work
      puts "Finished at #{DateTime.now}" if @options.verbose
    else
      output_usage
    end 
  end

  def parsed_options?
    # Specify options
    @opts = OptionParser.new 
    @opts.on('-v', '--version')    { output_version ; exit 0 }
    @opts.on('-h', '--help')       { output_help ; exit 0}
    @opts.on('-V', '--verbose')    { @options.verbose = true }
    @opts.on('--cwd', "Search for executables in working directory.")    { @options.cwd = true }
    @opts.on('-i', '--input INPUT', "Require the input folder") do |input|
      @options.input = input.gsub(/[#{File::SEPARATOR}]+$/, '')
    end
    @opts.on('-o', '--output PUTPUT', "Require the output folder") do |output|
      @options.output = output.gsub(/[#{File::SEPARATOR}]+$/, '')
    end
    @opts.on('-m', '--map NAME') do |map_name| 
      @options.map_name = map_name
    end
    # TO DO - add additional options
          
    @opts.parse!(@arguments) rescue return false
    
    process_options
    true      
  end

  # Setup the arguments
  def process_arguments

  end

  def output_help
    output_version
    output_usage
  end
  
  def output_usage
    puts @opts
  end
  
  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end

  # Performs post-parse processing on options
  def process_options
    
  end
  
  def output_options
    puts "Options:\n"
    
    @options.marshal_dump.each do |name, val|        
      puts "  #{name} = #{val}"
    end
  end

  # True if required arguments were provided
  def arguments_valid?
    true
  end
end

# Create and run the application
app = App.new(ARGV, STDIN)
app.run
