module Resource

  class Cron < Base

    block_attr :title, :command

    def initialize title, &block
      @command = ''
      @title = title
      self.instance_eval(&block)
    end

    def get_title
      @title
    end

    def run
      @command
    end

  end

end
