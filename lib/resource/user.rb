module Resource

  class User < Base

    block_attr :password, :uid, :gid, :shell, :action, :username

    def initialize username, &block
      set_base_defaults
      @username = username
      @shell = '/bin/bash'
      self.instance_eval(&block)
    end

    def run
      Execution.block 'Creating new user', @username, @owner do |b|
        b.always_run @always_run
        users = `cat /etc/passwd | grep "/home" |cut -d: -f1`
        users = users.scan(/[a-zA-Z\-_]+/)
        if users.include? @username
          Output.warn 'Aborted, I think this user already exists', users.inspect
        else
          b.run "useradd -b /home  -u #{@uid} -s #{@shell} -g #{@username} -m -k /home/#{@username} #{@username}"
        end
      end
    end

  end

end
