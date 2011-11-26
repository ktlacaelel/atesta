module Resource

  class Link < Base

    block_attr :source, :to, :owner, :group

    def initialize source, &block
      set_base_defaults
      @source = source
      @to = 'no_target'
      self.instance_eval(&block)
    end

    def run
      Execution.block 'Building Link', "#{@source} ~> #{@to}", @owner do |b|
        b.always_run @always_run
        b.run "mkdir -p #{::File.dirname(@to)}"
        b.run "mkdir -p #{::File.dirname(@source)}" unless ::File.exist?(::File.dirname(@source))
        b.run "touch #{@source}"
        b.run "rm -rf #{@source}"
        b.run "ln -s #{@to} #{@source}"
      end
    end

  end

end
