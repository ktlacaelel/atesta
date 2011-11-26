require 'rubygems'
require 'hashie'

class Node

  def self.set object
    @node = object
  end

  def self.get
    @node
  end

  def dna
    @dna
  end

  def self.magic matcher, path
    set resolve(matcher, path)
  end

  def self.resolve matcher, path
    Output.banner 'Loading', 'Merging default attributes...'
    @hash = @dna = eval(File.read path)
    Dir[matcher].each do |attr_file|
      next if File.directory? attr_file
      Output.info 'Merging node', attr_file
      @hash = @hash.deep_merge(eval(File.read attr_file) || {}).
        deep_merge(@hash)
    end
    # TODO: remove ARGV
    @hash[:instance_role] = ARGV[1]
    @hash[:platform] = 'ubuntu'
    Hashie::Mash.new(@hash)
  end

end

