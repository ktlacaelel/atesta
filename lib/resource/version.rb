module Resource

  class Version < Base

    block_attr :location, :current_version, :deployed_by, :deployed_time
    block_attr :server_info, :environment, :branch, :ip, :copy_to, :owner
    block_attr :reset

    def initialize location, &block
      set_base_defaults
      @location = location
      @current_version  = 'n/a'
      @deployed_by      = 'n/a'
      @server_info      = 'n/a'
      @environment      = 'n/a'
      @branch           = 'n/a'
      @ip               = 'n/a'
      @copy_to          = '/tmp/'
      @version = ::Deploy::Version.new
      self.instance_eval(&block)
    end

    def run
      Execution.block 'Deployment version file', @location, 'root' do |b|
        b.always_run true
        @version.deployed_by         = @deployed_by
        @version.current_version     = @current_version
        @version.add :server_info,     @server_info
        @version.add :environment,     @environment
        @version.add :branch,          @branch
        @version.add :reset,           @reset
        @version.add :ip,              @ip
        @version.store_to_file @location
        Output.info 'Copying version file to', @copy_to
        b.run "cp #{@location} #{@copy_to}"
        b.run "chown #{@owner}:#{@owner} #{@copy_to}/#{::File.basename(@location)}"
      end
    end

  end

end
