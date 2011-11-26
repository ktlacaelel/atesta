module Resource

  class File < Base

    block_attr :content, :owner, :group, :mode, :action, :target

    def initialize target, &block
      set_base_defaults
      @target = target
      self.instance_eval(&block)
    end

    # Compile any given string into a file remotely!
    #
    # 1. try to run everytime
    # 2. if file exists and current string checksum matches the old
    #    one skip it!
    # 3. otherwise just re-compile the file!
    #
    def run
      Execution.block 'Creating a custom file', @target, 'root' do |b|
        b.always_run true
        b.run "mkdir -p #{::File.dirname(@target)}"
        ::File.open(@target, 'w+') { |file| file.write @content }
        b.run "chown #{@owner}:#{@owner} #{::File.dirname(@target)}"
        b.run "chown #{@owner}:#{@owner} #{@target}"
        b.run "chmod #{unix_mode} #{@target}"
      end
    end

  end

end
