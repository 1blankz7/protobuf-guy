require_relative 'helper'
require_relative 'parser'


class Guy

  def initialize(args={})
    options = {
      :verbose => false,
      :input => '.',
      :output => '.',
      :map_name => 'MessageTypes.txt'
    }.merge(args)

    @verbose = options[:verbose]
    @input = options[:input]
    @output = options[:output]
    @map_name = options[:map_name]
    @os = Helper.os
  end

  def work
    if @verbose
      puts "Recursive search in: #{@input}"
    end

    if @verbose
      puts "Recursive search in: #{@input}"
    end

    # search input folder recursive
    files = Helper.recursive_proto_search(@input)

    if @verbose
      puts "Found #{files.count} proto file(s)"
    end
        
    FileUtils::mkdir_p "#{@output}"
    # save map of files  
    save_map(files, @output, @map_name)
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

  def build_classes(files, folder)
    filelist = files.join(" ")
    proto_options = ""
    import_path = "--proto_path=#{@input}"
    output_paths = "--java_out=#{folder}#{File::SEPARATOR}java --cpp_out=#{folder}#{File::SEPARATOR}cpp --python_out=#{folder}#{File::SEPARATOR}python"

    system_call = "#{Helper.getPathForExecutableFileInWorkingDirectory('protoc')} #{import_path} #{output_paths}  #{filelist}"
    
    #if @verbose
      puts "Call: #{system_call}" 
    #end

    system(system_call)

    if @os == :windows        

      protogenFilelist = files.join(" -i:")

      # system_call = "ProtoGen --proto_path=#{@input} -output_directory=#{folder}#{File::SEPARATOR}csharp #{filelist}"
      system_call = "#{Helper.getPathForExecutableFileInWorkingDirectory('protogen')} -i:#{protogenFilelist} -o:#{folder}#{File::SEPARATOR}csharp#{File::SEPARATOR}GeneratedMessages.cs"

      if @verbose
        puts "Call: #{system_call}" 
      end
      system(system_call)
    end
  end

end