
class Status; end

class << Status

  attr_accessor :status_file

  def status_file
    @status_file ||= '/tmp/deployment/env/status'
  end

  def load_or_create
    Output.info 'Loading status file', status_file
    `mkdir -p #{File.dirname(status_file)}`
    (File.exist? status_file) ? eval(File.read(status_file)) : {}
  end

  def get
    @status ||= Hashie::Mash.new(load_or_create)
  end

  def reload!
    Output.jump
    Output.info 'Reloading status', status_file
    save
    @status = nil
  end

  def save
    Output.info 'Saving deployment status to file', status_file
    File.open(status_file, 'w+') do |file|
      file.write Status.get.to_hash.inspect
    end
  end

end

