module Resource

  class Group < Base

    block_attr :groupname, :gid

    def initialize groupname, &block
      set_base_defaults
      @groupname = groupname
      self.instance_eval(&block)
    end

    def run
      Execution.block 'Creating new group', @groupname, 'root' do |b|
        b.always_run @always_run
        groups = `cat /etc/group | cut -d: -f1`
        groups = groups.scan(/[a-zA-Z\-_]+/)
        if groups.include? @groupname
          Output.warn 'Aborted, I think this group already exists', groups.inspect
        else
          b.run "groupadd -g #{@gid} #{@groupname}"
        end
      end
    end

  end

end
