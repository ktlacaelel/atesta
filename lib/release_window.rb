class ReleaseWindow

  def initialize releases_path, releases, window = 5, matcher = '*'
    @matcher = matcher
    @releases_path = releases_path
    @releases = releases.compact
    @window = window
  end

  def all_releases
    Dir[@releases_path + @matcher].map do |r|
      File.basename(r)
    end.compact
  end

  def deletable_releases
    all_releases - current_window
  end

  def current_window
    @releases.last(@window)
  end

  def deletable_files
    deletable_releases.map do |r|
      "#{@releases_path}#{r}"
    end
  end

end
