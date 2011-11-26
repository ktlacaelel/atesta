module Resource

  class Git < Base

    block_attr :owner, :repository, :sandbox_path, :sandbox_name
    block_attr :branch, :release_path, :timestamped, :swaping_branch
    block_attr :capsule_object

    def initialize repository, &block
      set_base_defaults
      @repository      = repository
      @sandbox_path    = '/tmp'
      @sandbox_name    = 'repository_sandbox'
      @always_run      = true
      @timestamped     = true
      @swaping_branch  = 'master'
      self.instance_eval(&block)
    end

    def run
      clone unless cloned?
      fetch_and_pull
      revision = revision(@branch)
      checkout revision
      key = @timestamped ? Time.now.strftime('%Y%m%d%H%M%S') : revision
      my_release_path = @release_path + key
      relocate my_release_path
      encapsulate_object revision, my_release_path, key
    end

    protected

    def encapsulate_object revision, my_release_path, key
      @capsule_object.release_path = my_release_path
      @capsule_object.revision     = revision
      @capsule_object.key          = key
    end

    def clone args = []
      Execution.block 'Cloning repository', @owner do |b|
        b.always_run @always_run
        b.run "git clone #{args.join(' ')} #{@repository} #{@sandbox_path}/#{@sandbox_name}", @sandbox_path
      end
    end

    def fetch_and_pull
      Execution.block 'Updating existing repository changes', @repository, @owner do |b|
        b.always_run @always_run
        b.run "git checkout #{@swaping_branch}", checkout_location
        b.run 'git fetch', checkout_location
        b.run 'git pull', checkout_location
      end
    end

    def relocate target
      Execution.block 'Installing snapshot of checkout', @owner, @owner do |b|
        b.always_run @always_run
        b.run "touch #{target}"
        b.run "rm -rf #{target}"
        b.run "cp -r #{checkout_location} #{target}"
        b.run "ls #{target} | column"
      end
    end

    def revision branch
      return @revision if @revision
      Execution.block "Extracting revision hash for", branch, @owner do |b|
        b.always_run @always_run
        b.run "git ls-remote #{@repository} #{branch}"
      end
      @revision = `sudo -u #{@owner} git ls-remote #{@repository} #{branch}`
      @revision = (@revision.scan /[a-zA-Z0-9]{40}/).first
    end

    def checkout revision
      Execution.block "Using revision to create new branch", "#{revision} ~> #{@owner}", @owner do |b|
        b.always_run @always_run
        b.run "git checkout #{@swaping_branch}", checkout_location
        b.run "git branch -f #{@owner}", checkout_location
        b.run "git branch -D #{@owner}", checkout_location
        b.run "git checkout -b #{@owner} #{revision}", checkout_location
      end
    end

    def checkout_location
      "#{@sandbox_path}/#{@sandbox_name}"
    end

    def remove
      Execution.block "Removing existing copy of repository: #{checkout_location}", @owner do |b|
        b.always_run @always_run
        b.run "rm -rf #{checkout_location}"
      end
    end

    def cloned?
      ::File.exist? checkout_location
    end

  end

end
