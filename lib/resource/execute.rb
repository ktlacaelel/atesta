module Resource

  class Execute < Base

    block_attr :owner, :title, :path

    def initialize title, &block
      set_base_defaults
      @path = nil
      @commands = []
      @title = title
      self.instance_eval(&block)
    end

    def command string
      @commands << { :command => string, :path => @path }
    end

    def run
      Execution.block 'Execution', @title, @owner do |b|
        b.always_run @always_run
        @commands.each do |command_hash|
          b.run "#{command_hash[:command]}", command_hash[:path]
        end
      end
    end

  end

end
