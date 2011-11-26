module Recipe

  attr_accessor :stack

  def change_binding binding
    @binding = binding
  end

  def init binding
    change_binding binding
    stack
  end

  def resource_not_supported *args
    Output.warn 'Resource not supported', args.inspect
  end

  def clean_stack!
    @stack = []
  end

  def cron_append object
    @cron_jobs << object
    Output.info 'Cron job detected', object.get_title
  end

  def cron_variable title, variable
    @cron_jobs ||= []
    @cron_vars ||= []
    @cron_vars << ''
    @cron_vars << "# #{title}"
    @cron_vars << variable
  end

  def setup_crontab
    Output.jump
    Output.info 'Setting up nice cron jobs', 'this is sweeet root crontab!'
    Output.ruler
    t = ::Tempfile.new('temporal_crontab')
    @cron_vars.each do |line|
      t.puts line
    end
    @cron_jobs.each do |resource|
      t.puts ''
      t.puts "# #{resource.get_title}"
      t.puts "#{resource.run}"
    end
    t.close
    system "cat #{t.path} | crontab"
    system 'crontab -l'
    t.unlink
  end

  def stack
    @stack ||= []
  end

  def stack_append object
    @stack << object
  end

  def template name, &block
    stack_append ::Resource::Template.new(name, &block)
  end

  def directory name, &block
    stack_append ::Resource::Directory.new(name, &block)
  end

  def gem_package name, &block
    stack_append ::Resource::Gem.new(name, &block)
  end

  def package package_name, &block
    block = Proc.new {} unless block
    stack_append ::Resource::Package.new(package_name, &block)
  end

  def execute title, &block
    stack_append ::Resource::Execute.new(title, &block)
  end

  def user username, &block
    stack_append ::Resource::User.new(username, &block)
  end

  def link source, &block
    stack_append ::Resource::Link.new(source, &block)
  end

  def git repository, &block
    stack_append ::Resource::Git.new(repository, &block)
  end

  def cron title, &block
    cron_append ::Resource::Cron.new(title, &block)
  end

  def service name, &block
    stack_append ::Resource::Service.new(name, &block)
  end

  def system_group groupname, &block
    stack_append ::Resource::Group.new(groupname, &block)
  end

  def remote_file target, &block
    stack_append ::Resource::RemoteFile.new(target, &block)
  end

  def file target, &block
    stack_append ::Resource::File.new(target, &block)
  end

  def swap_release release_path, &block
    stack_append ::Resource::SwapRelease.new(release_path, &block)
  end

  def version location, &block
    stack_append ::Resource::Version.new(location, &block)
  end

  def hook target
    target = status.release_path + "/deploy/#{target}.rb"
    Resource::Hook.new(target, @binding).run
  end

  def node
    @node ||= ::Node.get
  end

  def include_recipe name
    @recipes ||= []
    if @recipes.include? name
      Output.warn 'Already loaded recipe with name', name
      return
    end
    @recipes << name
    Output.info 'Including recipe', name
    include_file :Recipe, @recipes_target % name
  end

  def include_file file_type, some_file
    unless ::File.exist? some_file
      Output.warn "#{file_type} file not found (skipping)", some_file
      return
    end
    eval(File.read(some_file), @binding)
    Output.info 'Executable units', stack.size
  end

  def load_recipes recipes_target, list
    Output.banner 'Loading', 'Instantiating recipes...'
    @recipes_target = recipes_target
    list.each { |recipe| include_recipe recipe }
  end

  def summary
    Output.banner 'Printing', 'Execution summary'
    Output.info 'Total Recipes', node[:recipes].size
    Output.info 'Total executable stack units', stack.size
  end

  def status
    Status.get
  end

  def transaction &block
    yield
  rescue => e
    Output.error 'Rolling back', ' =:D '
    raise e
  end

  def whoami
    (File.exist? 'env/whoami') ? File.read('env/whoami').chop : 'Unknown user'
  end

  def server_ip_address
    (File.exist? 'env/ip') ? File.read('env/ip').chop : 'Unknown ip address'
  end

end
