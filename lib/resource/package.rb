module Resource

  class Package < Base

    block_attr :action, :package_name, :owner

    def initialize package_name, &block
      set_base_defaults
      @package_name = package_name
      self.instance_eval(&block)
    end

    def run
      Execution.block 'Installing Package', @package_name, @owner do |b|
        b.always_run @always_run
        b.run "apt-get install -y #{@package_name}"
      end
    end

    def value_for_platform *args
      @package_name
    end

  end

end
