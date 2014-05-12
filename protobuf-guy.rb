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
      File.open("#{folder}#{File::SEPARATOR}#{map_name}", 'w') do |map|
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
      filelist = files.join(" ")
      proto_options = ""
      import_path = "--proto_path=#{@options.input}"
      output_paths = "--java_out=#{folder}#{File::SEPARATOR}java --cpp_out=#{folder}#{File::SEPARATOR}cpp --python_out=#{folder}#{File::SEPARATOR}python"

      system_call = "protoc #{import_path} #{output_paths}  #{filelist}"
      
      if @options.verbose        
        puts "Call: #{system_call}" 
      end

      system(system_call)

      if @os == :windows        

        system_call = "ProtoGen --proto_path=#{@options.input} -output_directory=#{folder}#{File::SEPARATOR}csharp #{filelist}"

        if @options.verbose        
          puts "Call: #{system_call}" 
        end
        system(system_call)

      end
    end
    
    def process_command
      if @options.verbose
        puts "Recursive search in: #{@options.input}"
      end

      if @options.verbose
        puts "Search binary: protoc"
      end

      # try to find protoc
      protoc = which('protoc')
      # terminate if not found
      unless protoc
        puts "Can't find 'protoc' in PATH"
        return
      end

      if @options.verbose
        puts "Found 'protoc' in #{protoc}" 
        puts "Search binary: ProtoGen"
      end


      if @os == :windows
        # if on windows try to find ProtoGen
        # terminate if not found
        protogen = which('ProtoGen')
        unless protogen
          puts "Can't find 'ProtoGen' in PATH"
          return
        end

        if @options.verbose        
          puts "Found 'ProtoGen' in #{protogen}" 
        end
      end    

      if @options.verbose
        puts "Recursive search in: #{@options.input}"
      end

      # search input folder recursive
      files = recursive_search(@options.input)

      if @options.verbose
        puts "Found #{files.count} proto file(s)"
      end
          
      FileUtils::mkdir_p "#{@options.output}"
      # save map of files  
      save_map(files, @options.output, @options.map_name)
      # clear output dir
      FileUtils.rm_rf("#{@options.output}#{File::SEPARATOR}python")
      FileUtils.rm_rf("#{@options.output}#{File::SEPARATOR}java")
      FileUtils.rm_rf("#{@options.output}#{File::SEPARATOR}cpp")
      FileUtils.rm_rf("#{@options.output}#{File::SEPARATOR}csharp")
      # create folders
      FileUtils::mkdir_p "#{@options.output}#{File::SEPARATOR}python"
      FileUtils::mkdir_p "#{@options.output}#{File::SEPARATOR}java"
      FileUtils::mkdir_p "#{@options.output}#{File::SEPARATOR}cpp"
      FileUtils::mkdir_p "#{@options.output}#{File::SEPARATOR}csharp"
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



# Cross-platform way of finding an executable in the $PATH.
#
#   which('ruby') #=> /usr/bin/ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  return nil
end

# Create and run the application
app = App.new(ARGV, STDIN)
app.run
