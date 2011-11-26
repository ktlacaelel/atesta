require 'erubis'

module Resource

  class Template < Base

    class_attr :source

    block_attr :owner, :group, :mode, :source, :action, :variables, :backup, :target

    PREFIX = ''

    def run
      Execution.block 'Compiling template file', @target, @owner do |b|
        compile!
        b.always_run @always_run
      end
      Execution.block 'Ensuring file permissions', @target, 'root' do |b|
        b.run "chown #{@owner}:#{@owner} #{@target}"
        b.run "chmod #{unix_mode} #{@target}"
        b.always_run @always_run
      end
    end

    protected

    def initialize target, &block
      set_base_defaults
      @target = target
      ensure_target_zone
      self.instance_eval(&block)
    end

    def target_path
      "#{PREFIX}#{@target}"
    end

    def needs_compilation?
      return true unless ::File.exist?(target_path)
      MD5.hexdigest(::File.read target_path) != MD5.hexdigest(compile_template)
    end

    def compile!
      Output.info 'Erubis is compiling', target_path
      ::File.open(target_path, 'w+') { |file| file.write(compile_template) }
    end

    def ensure_target_zone
      system "mkdir -p #{PREFIX}#{::File.dirname(@target)}"
      true
    end

    def find_source
      Dir['cookbooks/*/templates/*/*.*'].each do |file|
        return file if file.include? ::File.basename(@source)
      end
    end

    def compile_template
      @compile_template ||=
      Erubis::Eruby.new(::File.read(find_source)).evaluate(
        { :node => Node.get }.merge(@variables || {})
      )
    end

  end

end
