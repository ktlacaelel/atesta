module Resource

  class Directory < Base

    block_attr :owner, :group, :mode, :action, :recursive, :target

    def initialize target, &block
      set_base_defaults
      @target = target
      self.instance_eval(&block)
    end

    def run
      Execution.block 'Creating directory', @target, 'root' do |b|
        b.always_run @always_run
        b.run "mkdir -p #{@target}"
        b.run "chmod #{unix_mode} #{@target}"
        b.run "chown #{@owner}:#{@group} #{@target}"
      end
    end

  end

end
