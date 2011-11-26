require 'rubygems'
require 'isna'

module Output

  CHAR = '#'
  RULER = '='

  def self.jump
    puts ''
  end

  def self.ruler type_of_output = :info
    puts "[%s;%s;%sm#{CHAR} #{RULER * 77}[0m" % type_for(type_of_output)
  end

  def self.banner key, value, type_of_output = :info
    jump
    kv key, value, type_for(type_of_output)
    ruler type_of_output
  end

  def self.command code
    puts "[0;36;1m#{code}[0m"
  end

  def self.type_for symbol
    return [0, 32, 1] if symbol == :info
    return [0, 33, 1] if symbol == :warn
    return [5, 31, 1] if symbol == :error
    [1, 36, 1]
  end

  def self.info key, value
    kv key, value, self.type_for(:info)
  end

  def self.warn key, value
    kv key, value, type_for(:warn)
  end

  def self.error key, value
    kv key, value, type_for(:error)
  end

  def self.kv key, value, combo
    puts "[%s;%s;%sm#{CHAR} #{key}[0m: [0;0m#{value}[0m" % combo
  end

end
