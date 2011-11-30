
class Status; end

class << Status

  # TODO: extract this from class
  FILE = '/tmp/deployment/env/status'

  def load_or_create
    Output.info 'Loading status file', FILE
    `mkdir -p #{File.dirname(FILE)}`
    (File.exist? FILE) ? eval(File.read(FILE)) : {}
  end

  def get
    @status ||= Hashie::Mash.new(load_or_create)
  end

  def reload!
    Output.jump
    Output.info 'Reloading status', FILE
    save
    @status = nil
  end

  def save
    Output.info 'Saving deployment status to file', FILE
    File.open(FILE, 'w+') do |file|
      file.write Status.get.to_hash.inspect
    end
  end

end

