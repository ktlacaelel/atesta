module Resource

  class Gem < Base

    block_attr :version, :source, :action, :owner, :name

    def initialize name, &block
      set_base_defaults
      @owner = 'root'
      @name = name
      self.instance_eval(&block)
    end

    def run
      command = []
      command << "gem install #{@name}"
      command << "--source #{@source}" if @source
      command << "--version #{@version}" if @version
      Execution.block 'Installing gem', @name, @owner do |b|
        b.always_run @always_run
        b.run(command * ' ')
      end
    end

  end

end
