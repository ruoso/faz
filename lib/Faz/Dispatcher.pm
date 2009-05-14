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
    @!public = @(%!actions.values.grep: { $_ ~~ Faz::Action::Public }).sort: { $_.priority }
  }

  # this method freezes the regexes, combining them into a single
  # regular expression that will evaluate the request and return the
  # desired action.
  method compile {
    warn "Registered Actions ({%!actions.keys.elems}):";
    warn join "\n", %!actions.keys;

    warn "Public Actions ({@!public.elems}):";
    warn join "\n", map { .private-name }, @!public;

    my sub buildspec($act) {
      my &action_capture = $act.regex;
      my &closure = -> $/ {
        make $act;
        my $in = $/.new($/);
        $in.to = $in.from; $in;
      };
      if $act.parent {
        my &parent_action_capture = buildspec($act.parent);
        my $t = token { <parent_action_capture> <action_capture> <?closure> };
        return $t;
      } else {
        my $t = token { <action_capture> <?closure> };
        return $t;
      }
    }

    my @subregexes = map { buildspec($_) }, @!public;

    my &subrx = sub ($/) {
      for @subregexes -> &eachrx {
        my $match = Match.new($/);
        my $result = eachrx($match);
        if $result {
           return $result;
        };
      };
      return Match.new($/);
    };

    warn 'Compiling regexes.';
    $!regex = token { <subrx> };

    # I get a null pmc in isa_pmc() if without this line...
    1;
  }

  method dispatch() {
    unless defined $!regex {
      warn 'Compiling regexes at dispatch time.';
      self.compile;
    }
    if $*request.uri.path ~~ $!regex {
      my $action = $<subrx>.ast;
      warn "Path '{$*request.uri.path}' matched '{$action.private-name}'";
      my %named = %($<subrx><action_capture>);
      my @pos = @($<subrx><action_capture>);
      %named<parent_action_capture> = $<subrx><parent_action_capture>;
      self.run-action($action, |@pos, |%named );
    } else {
      warn "No action matched '{$*request.uri.path}'";
      1;
    }
  }

  method run-action($action, *@pos, *%named) {
    $*action = $action;
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
# TODO: rakudo don't know how to handle control exceptions yet.
#    CONTROL {
#      when Faz::ControlExceptionDetach {
#        self.run-action(%!actions{$_.path}, |$_.capture);
#      }
#    }
    1;
  }
}
