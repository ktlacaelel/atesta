module Resource

  class Service < Base

    block_attr :action

    def initialize name, &block
      set_base_defaults
      @name       = name
      @always_run = true
      self.instance_eval(&block)
    end

    def run
      Execution.block "Changing #{@name} service", @action, 'root' do |b|
        b.always_run @always_run
        b.run "/etc/init.d/#{@name} #{@action}"
      end
    end

  end

end
