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

class App
  VERSION = '0.1'
  
  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin
    
    # Set defaults
    @options = OpenStruct.new
    @options.verbose = false
    @options.input = '.'
    @options.output = '.'
    @options.map_name = 'MessageTypes.txt'
    @opts
  end

  # Parse options, check arguments, then process the command
  def run
        
    if parsed_options? && arguments_valid? 
      
      puts "Start at #{DateTime.now}\
\
" if @options.verbose
      
      output_options if @options.verbose # [Optional]
            
      process_arguments   
      os         
      process_command
      
      puts "\
Finished at #{DateTime.now}" if @options.verbose
      
    else
      output_usage
    end
      
  end
  
  protected
  
    def parsed_options?
      
      # Specify options
      @opts = OptionParser.new 
      @opts.on('-v', '--version')    { output_version ; exit 0 }
      @opts.on('-h', '--help')       { output_help ; exit 0}
      @opts.on('-V', '--verbose')    { @options.verbose = true }  
      @opts.on('-i', '--input INPUT', "Require the input folder") do |input| 
        @options.input = input
      end
      @opts.on('-o', '--output PUTPUT', "Require the output folder") do |output| 
        @options.output = output
      end
      @opts.on('-m', '--map NAME') do |map_name| 
        @options.map_name = map_name
      end
      # TO DO - add additional options
            
      @opts.parse!(@arguments) rescue return false
      
      process_options
      true      
    end

    # Performs post-parse processing on options
    def process_options
      
    end
    
    def output_options
      puts "Options:\
"
      
      @options.marshal_dump.each do |name, val|        
        puts "  #{name} = #{val}"
      end
    end

    # True if required arguments were provided
    def arguments_valid?
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


    # check current os
    def os
      @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        else
          raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
      )
    end

    def recursive_search(folder)
      Dir.glob("#{folder}/**/*.proto")
    end

    def save_map(files, folder, map_name)
      File.open("#{folder}/#{map_name}", 'w') do |map|
        index = 0
        files.each do |file|
          parser = Parser.new(file)
          messages = parser.parse
          messages.each do |message|
            map.write("#{index},#{message}\n")
            index += 1
          end
        end
      end
    end

    def build_classes(files, folder)

      files.each do |file|
        if @os == :linux || @os == :macosx
          system("protoc --python_out=#{folder}python #{file}")
          system("protoc --java_out=#{folder}java #{file}")
          system("protoc --cpp_out=#{folder}cpp #{file}")
        elsif @os == :windows
          system("protoc --python_out=#{folder}python #{file}")
          system("protoc --java_out=#{folder}java #{file}")
          system("protoc --cpp_out=#{folder}cpp #{file}")
          system("ProtoGen --proto_path=#{folder} -output_directory=#{folder}csharp #{file}")
        end
      end
    end
    
    def process_command
      # search input folder recursive
      files = recursive_search(@options.input)
      # save map of files
      save_map(files, @options.output, @options.map_name)
      # clear output dir
      FileUtils.rm_rf("#{@options.output}python")
      FileUtils.rm_rf("#{@options.output}java")
      FileUtils.rm_rf("#{@options.output}cpp")
      FileUtils.rm_rf("#{@options.output}csharp")
      # create folders
      FileUtils::mkdir_p "#{@options.output}python"
      FileUtils::mkdir_p "#{@options.output}java"
      FileUtils::mkdir_p "#{@options.output}cpp"
      FileUtils::mkdir_p "#{@options.output}csharp"
      # build classes
      build_classes(files, @options.output)
    end
end

class Parser 

  def initialize(filename)
    @filename = filename
  end

  def parse
    array = Array.new
    File.open(@filename, "r") do |infile|
      while (line = infile.gets)
        pos = line =~ /message \w+ *\{/
        if pos
          level = (pos / 2).floor
          if array.length <= level
            array << Array.new
          end
          name = ""
          if level > 0
            name = "#{array[level-1][-1]}."
          end

          name = "#{name}#{line[pos + 8 .. (line.index(/ *\{/) - 1)]}"
          array[level] << name
        end
      end
    end

    return array.flatten
  end
end

# Create and run the application
app = App.new(ARGV, STDIN)
app.run
