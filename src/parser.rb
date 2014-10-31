class Parser
  @@debug = false

  class LineCounter
    attr_accessor :currentLine

    def initialize
      @currentLine = 0
    end
  end

  def initialize(filename)
    @filename = filename
  end

  def removeCommentFromLine(line)
    return line.split('//')[0]
  end

  def searchForMessageInLine(line)
    line =~ /message (\w+)/
    return $1
  end

  def searchForOpeningBraceInLine(line)
    return line =~ /{/
  end

  def searchForClosingBraceInLine(line)
    return line =~ /}/
  end

  # Parses a file and returns all its contained messages.
  # Each new nested message is identified by the "message [messageName] {" pattern.
  def getMessages(lineIterator)
    getMessagesRecursion("", lineIterator, LineCounter.new())
  end

  def getMessagesRecursion(enclosingMessageName, lineIterator, lineCounter)
    foundMessages = Array.new

    if (@@debug)
      puts "We are currently in message " + enclosingMessageName + " at line " + lineCounter.currentLine.to_s
    end

    nestedBraceLevel = 0

    while (line = lineIterator.gets)
      lineCounter.currentLine += 1

      # Remove protobuf comments from the current line before processing it any further.
      line = removeCommentFromLine(line)

      # Check if there is a nested message in this line.
      nestedMessageName = searchForMessageInLine(line)

      if (nestedMessageName)
        # We found a nested message in this line.
        # Add a prefix to the message name.
        nestedMessageName = enclosingMessageName + nestedMessageName

        foundMessages << nestedMessageName

        # Fast forward until we have found the opening brace of this nested message
        lookForOpeningBraceInNextLineForNestedMessage = !searchForOpeningBraceInLine(line)
        if (lookForOpeningBraceInNextLineForNestedMessage)
          while (line = lineIterator.gets)
            lineCounter.currentLine += 1
            if (searchForOpeningBraceInLine(line))
              break
            end
          end
        end

        # Start a recursion to get the nested messages of the nested message.
        foundMessages.concat(getMessagesRecursion(nestedMessageName + ".", lineIterator, lineCounter))
        next
      end

      if (searchForOpeningBraceInLine(line))
        nestedBraceLevel += 1
        if (@@debug)
          puts nestedBraceLevel.to_s + " in line " + lineCounter.currentLine.to_s
        end
      end

      # Look for the end of the message
      if (searchForClosingBraceInLine(line))
        if (nestedBraceLevel < 1)
          if (@@debug)
            puts "FOUND closing brace for message: " + enclosingMessageName + " in line " + lineCounter.currentLine.to_s
          end
          break
        end
        nestedBraceLevel -= 1

        if (@@debug)
          puts nestedBraceLevel.to_s + " in line " + lineCounter.currentLine.to_s
        end
      end
    end

    return foundMessages
  end

  def parse
    foundMessages = Array.new

    File.open(@filename, "r") do |lineIterator|

      foundMessages = getMessages(lineIterator)

      if (@@debug)
        puts "These are the messages I found:"
        puts foundMessages
      end

      return foundMessages
    end
  end
end