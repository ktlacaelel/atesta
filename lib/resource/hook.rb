module Resource

  class Hook < Base

    def initialize target, binding
      @target = target
      @binding = binding
    end

    def run
      if ::File.exist?(@target)
        Output.info 'Hook found', @target
        eval(::File.read(@target), @binding)
      else
        Output.warn 'Hook not found', @target
      end
    end

    def should_skip?
      false
    end

  end

end
