class Parser

  def initialize(filename)
    @filename = filename
  end

  def searchForMessageInLine(line)
    line =~ /message (\w+)/
    return $1
  end

  def searchForBraceInLine(line)
    return line =~ /\w* *\{/
  end

  def parse
    foundMessages = Array.new
    File.open(@filename, "r") do |infile|
      # Remember the nesting class depth we are currently at. Currently this isn't used anywhere, but may become handy in the future.
      level = 0

      # Remember the name of the last message we found.
      currentMessageName = ""

      # Each new nested message is identified by the "message [messageName] {" pattern. But the brace can be located in a following line.
      # Since we are reading the file line by line, we need to remember, if we are looking for a brace. This is essentially a very simple parser.
      lookingForBraceInNextLine = false

      while (line = infile.gets)
        if (!lookingForBraceInNextLine)
          # We are currently looking for a new message.
          tmpMessageName = searchForMessageInLine(line)

          if (!tmpMessageName)
            # If there is no message in this line, there is nothing of interest here.
            next
          else
            # Otherwise we found a new message in this line.
            currentMessageName = tmpMessageName
          end

          # Lets see if there is a brace in this line.
          if (!searchForBraceInLine(line))
            # If there is no brace in this line, we need to continue looking in the next lines.
            lookingForBraceInNextLine = true
            next
          else
            # We found a brace in this line.
            lookingForBraceInNextLine = false
            foundMessages << currentMessageName
            level += 1
            next
          end
        else
          if (!searchForBraceInLine(line))
            # If there is no brace in this line, we need to continue looking in the next lines.
            lookingForBraceInNextLine = true
            next
          else
            # We found a brace in this line.
            lookingForBraceInNextLine = false
            foundMessages << currentMessageName
            level += 1
            next
          end
        end
      end

      puts "These are the messages I found:"
      puts foundMessages

      return foundMessages
    end
  end
end