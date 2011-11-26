module Resource

  class Base

    include ::BlockAttr
    include ::ClassAttr

    # Access child's class_name statically
    class_attr :class_name

    # This resource should be executed always??
    # *boolean*
    block_attr :always_run

    # Setup class name
    def self.inherited name
      @class_name = name
    end

    # Translate octal to decimal modes
    def unix_mode
      @mode.to_i.to_s(8)
    end

    # Configure default settings for any resource
    def set_base_defaults
      @not_if     = false
      @owner      = 'root'
      @always_run = false
    end

    def not_if condition = nil, &block
      if condition.is_a?(String)
        if system(condition)
          @not_if = true
        end
      end
      if block_given? && yield
        @not_if = true
      end
    end

    def should_skip?
      @not_if == true
    end

  end

end
