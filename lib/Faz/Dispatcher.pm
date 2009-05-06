use Faz::Action;
use Faz::Action::Public;
# the dispatcher catalogs all actions, and is responsible for
# actually trying to invoke them
role Faz::Dispatcher {
  has %!actions;
  has @!public;
  has $!regex;

  method register-action (Faz::Action $a) {
    fail 'Duplicated action'
      if %!actions.exists($a.private-name);
    %!actions{$a.private-name} = $a;
    if $a ~~ Faz::Action::Public {
      @!public = (@!public, $a).sort: { $_.priority }
    }
  }

  # this method freezes the regexes, combining them into a single
  # regular expression that will evaluate the request and return the
  # desired action.
  method compile {

    my sub buildspec($act) {
      my &action_capture = $act.regex;
      my &closure = -> $/ {
        make $act;
        my $in = $/.new($/);
        $in.to = $in.from; $in;
      };
      if $act.parent {
        my &parent_action_capture = buildspec($act.parent);
        return token { <parent_action_capture> <action_capture> <?closure> };
      } else {
        return token { <action_capture> <?closure> };
      }
    }

    my @subregexes = map { buildspec($_) }, @!public;

    my &subrx = sub ($/) {
      for @subregexes -> &eachrx {
        my $result = eachrx($/);
        if $result {
           return $result;
        };
      };
      return Match.new($/);
    };

    $!regex = token { <subrx> };

    # I get a null pmc in isa_pmc() if without this line...
    1;
  }

  method dispatch() {
    self.compile;
# rakudo does not support contextual variables yet
#    if $*request.uri.path ~~ $!regex {
    if '/blog/faz/bla' ~~ $!regex {
      my %named = %($<subrx><action_capture>);
      my @pos = @($<subrx><action_capture>);
      %named<parent_action_capture> = $<subrx><parent_action_capture>;
      self.run-action($<subrx>.ast, |@pos, |%named );
    } else {
      say 'failed';
      fail 'No action matched';
    }
  }

  method run-action($action is context, *@pos, *%named) {
    my $errors is context<rw>;
    {
      $action.*begin(|@pos, |%named);
      $action.*execute(|@pos, |%named);
      CATCH {
        say $!;
        $errors = $! if $!;
      }
    }
    $action.*finish(|@pos, |%named);
# we don't know how to handle control exceptions yet.
#    CONTROL {
#      when Faz::ControlExceptionDetach {
#        self.run-action(%!actions{$_.path}, |$_.capture);
#      }
#    }
    1;
  }
}
