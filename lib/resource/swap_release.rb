module Resource

  class SwapRelease < Base

    block_attr :owner, :release_path, :current

    def initialize release_path, &block
      set_base_defaults
      @release_path = release_path
      self.instance_eval(&block)
    end

    def run
      Execution.block 'Swaping releases', "#{@current} ~> #{@release_path}", 'root' do |b|
        b.always_run true
        b.run "touch #{@current.chop}"
        b.run "rm #{@current.chop}"
        b.run "ln -s #{@release_path} #{@current.chop}"
        b.run "chown #{@owner}:#{@owner} #{@current.chop}"
      end
    end

  end

end
