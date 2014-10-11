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