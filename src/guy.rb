require_relative 'helper'
require_relative 'parser'


class Guy
  
  def initialize(args={})
    options = {
        :verbose => false,
        :input => '.',
        :output => '.',
        :map_name => 'MessageTypes.txt',
        :not_installed => false
    }.merge(args)

    @verbose = options[:verbose]
    @input_folder = options[:input]
    @output_folder = options[:output]
    @map_name = options[:map_name]
    @os = Helper.os
    @use_working_dir = options[:not_installed]

    @input = Helper.convertFilePathToUnix(@input_folder)
    @output = Helper.convertFilePathToUnix(@output_folder)
  end

  def work
    if not @use_working_dir
      if @verbose
        puts "Search binary: protoc"
      end
      # try to find protoc
      protoc = Helper.which('protoc')
      # terminate if not found
      unless protoc
        puts "Can't find 'protoc' in PATH"
        return
      end

      if @verbose
        puts "Found 'protoc' in #{protoc}" 
        puts "Search binary: ProtoGen"
      end

      if @os == :windows
        # if on windows try to find ProtoGen
        # terminate if not found
        protogen = Helper.which('ProtoGen')
        unless protogen
          puts "Can't find 'ProtoGen' in PATH"
          return
        end

        if @verbose        
          puts "Found 'ProtoGen' in #{protogen}" 
        end
      end
    end

    if @verbose
      puts "Recursive search in: #{@input_folder}"
    end
    if @verbose
      puts "Recursive search in: #{@input}"
    end

    # search input folder recursive
    files = Helper.recursive_proto_search(@input_folder)

    if @verbose
      puts "Found #{files.count} proto file(s)"
    end

    reset_output_folder
    # save map of files  
    save_map(files, @output, @map_name)
    # build classes
    build_classes(files, @output)
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

  def reset_output_folder
    FileUtils::mkdir_p "#{@output}"
    # clear output dir
    FileUtils.rm_rf("#{@output}#{File::SEPARATOR}python")
    FileUtils.rm_rf("#{@output}#{File::SEPARATOR}java")
    FileUtils.rm_rf("#{@output}#{File::SEPARATOR}cpp")
    FileUtils.rm_rf("#{@output}#{File::SEPARATOR}csharp")
    # create folders
    FileUtils::mkdir_p "#{@output}#{File::SEPARATOR}python"
    FileUtils::mkdir_p "#{@output}#{File::SEPARATOR}java"
    FileUtils::mkdir_p "#{@output}#{File::SEPARATOR}cpp"
    FileUtils::mkdir_p "#{@output}#{File::SEPARATOR}csharp"
  end

  def build_classes(files, folder)
    filelist = files.join(" ")
    proto_options = ""
    import_path = "--proto_path=#{@input}"
    # TODO: build string in loop
    output_paths = "--java_out=#{folder}#{File::SEPARATOR}java --cpp_out=#{folder}#{File::SEPARATOR}cpp --python_out=#{folder}#{File::SEPARATOR}python"
    protoc_executable = 'protoc'

    if @use_working_dir
      protoc_executable = Helper.getPathForExecutableFileInWorkingDirectory(protoc_executable)
    end

    if (@os == :windows)
      import_path = Helper.convertFilePathToWindows(import_path)
      output_paths = Helper.convertFilePathToWindows(output_paths)
      protogenExecutable = Helper.convertFilePathToWindows(Helper.getPathForExecutableFileInWorkingDirectory('ProtoGen'))
      outputFolder = Helper.convertFilePathToWindows(folder) + "\\csharp\\"
    end

    threads = Array.new()

    files.each { |file|
      protoGenerateThread = Thread.new {
        threadLocalFile = file

        system_call_0 = "#{protoc_executable} #{import_path} #{output_paths} #{threadLocalFile}"

        if @verbose
          puts "Call: #{system_call_0}"
        end

        system(system_call_0)

        if @os == :windows
          fileName = File.basename(file, ".proto")

          system_call_1 = "#{protogenExecutable} -i:#{Helper.convertFilePathToWindows(threadLocalFile)} -o:#{outputFolder}#{fileName}.cs"

          if @verbose
            puts "\nCall: #{system_call_1}\n"
          end

          system(system_call_1)
        end
      }

      threads << protoGenerateThread
    }

    for thread in threads
      thread.join()
    end
  end

end