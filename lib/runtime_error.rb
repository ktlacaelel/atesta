class RuntimeError

  def initialize *args
    Status.save
    super
  end

end
