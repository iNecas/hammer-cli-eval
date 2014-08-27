module HammerCLIEval

  class Context

    def initialize(hammer)
      @hammer = hammer
    end

    def api
      @api ||= HammerCLI::Connection.get("foreman").api
    end

    def foreman
      @foreman ||= ApipieBindings::Model::App.new(api, 'Foreman')
    end

    def pry
      require 'pry'
      binding.pry
    end
  end
end
