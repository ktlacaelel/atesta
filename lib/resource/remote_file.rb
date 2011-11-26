module Resource

  class RemoteFile < Base

    block_attr :owner, :group, :mode, :source

    # Install a static local file into a remote server.
    def initialize target, &block
      set_base_defaults
      @pattern = 'cookbooks/*/files/default/'
      @target = target
      self.instance_eval(&block)
    end

    def content
      (Dir[@pattern + '*'] + Dir[@pattern + '*.*']).each do |file|
        return ::File.read(file) if file.include? @source
      end
      'Resource was not found'
    end

    def run
      Execution.block 'Creating a remote file', @target, @owner do |b|
        if ::File.exist? @target
          sums_equal = MD5.hexdigest(::File.read(@target)) == MD5.hexdigest(content)
        else
          sums_equal = false
          @always_run = true
        end
        if sums_equal
          Output.warn 'Skipping', 'checksum comparison matches'
        else
          Output.warn 'Generating file with ruby', @target
          ::File.open(@target, 'w+') { |file| file.write content }
          b.always_run @always_run
          b.run "chown #{@owner}:#{@group} #{@target}"
          b.run "chmod #{unix_mode} #{@target}"
        end
      end
    end

  end

end
