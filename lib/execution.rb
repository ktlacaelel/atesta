require 'md5'

class Execution

  attr_accessor :user, :always_run

  def initialize title, value
    @commands   = []
    @title      = title
    @value      = value
    @always_run = false
  end

  def ignore
    Output.jump
    Output.error 'Ignoring execution', '..'
    Output.ruler
  end

  def always_run boolean
    @always_run = boolean
  end

  def banner
    Output.jump
    Output.info @title, @value
    # Output.info 'Hash', serialize
    Output.ruler
  end

  def serialize
    MD5.hexdigest @title + (@commands * '')
  end

  def self.block title, value = nil, user = 'deploy', &block
    @object         = new(title, value)
    @object.user    = user
    @object.execute &block
  end

  def execute &block
    banner
    yield(self)
    run_commands
  end

  def run_commands
    st = Status.get
    st.execution!.hashes = [] unless st.execution.respond_to?(:hashes)
    if st.execution.hashes.include?(serialize)
      Output.warn 'Ignoring', 'Already executed..'
    end
    if @always_run
      Output.warn 'Always run switch detected', 'Forcing execution!'
    end
    @commands.map { |cmd| code_for(cmd) }.each do |code|
      Output.command code
      unless @always_run
        next if st.execution.hashes.include? serialize
      end
      run_or_raise code
    end
    unless st.execution.hashes.include? serialize
      st.execution.hashes << serialize
    end
    nil
  end

  def run_or_raise code
    return if system code
    Output.jump
    Output.ruler :error
    Output.error 'EXECUTION FAILED', code
    Output.ruler :error
    raise 'Que pedo!'
  end

  def code_for cmd
    if cmd[:path]
      "cd #{cmd[:path]} && sudo -u #{@user} #{cmd[:command]}"
    else
      "sudo -u #{@user} #{cmd[:command]}"
    end
  end

  def run string, path = nil
    @commands << { :command => string, :path => path }
  end

  def command string, path = nil
    run string, path
  end

end

