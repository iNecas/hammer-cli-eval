module HammerCLIEval

  class EvalCommand < HammerCLI::AbstractCommand
    def execute
      HammerCLIEval::Context.new(self).pry
    end
  end

  HammerCLI::MainCommand.subcommand('eval',
                                    'eval Ruby code in hammer context',
                                    HammerCLIEval::EvalCommand)
end
