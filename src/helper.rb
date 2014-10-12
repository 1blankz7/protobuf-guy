class Helper
  # Checks the current running os
  # 
  # Returns the current host os as a label
  def self.os
    os ||= (
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
    os
  end

  # Find all proto files in a given folder recursively
  #
  # Returns list of file paths
  def self.recursive_proto_search(folder)
    Dir.glob("#{folder}/**/*.proto")
  end

  # Cross-platform way of finding an executable in the $PATH.
  #
  #   which('ruby') #=> /usr/bin/ruby
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable? exe
      }
    end
    return nil
  end
end