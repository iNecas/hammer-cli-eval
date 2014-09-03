module HammerCLIEval

  def self.exception_handler_class
    HammerCLIKatello::ExceptionHandler
  end

  class EvalCommand < HammerCLI::AbstractCommand

    option '--file', 'FILE', 'File to evaluate'

    def execute
      context = HammerCLIEval::Context.new(self)
      if option_file
        context.instance_eval(File.read(option_file), option_file, 1)
      else
        context.pry
      end
      return HammerCLI::EX_OK
    end
  end

  HammerCLI::MainCommand.subcommand('eval',
                                    'eval Ruby code in hammer context',
                                    HammerCLIEval::EvalCommand)
end
