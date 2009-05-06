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
      my &rx = $act.regex;
      my &closure = -> $/ { say 'closure'; make $act };
      if $act.parent {
        my &pr = buildspec($act.parent);
        return token { $<actcap> = ( $<_parent_action_capture> = <pr> <rx> ) <closure> };
      } else {
        return token { $<actcap> = <rx> <closure> };
      }
    }

    my @subregexes = map { buildspec($_) }, @!public;

    my &subrx = -> $/ {
      say 'subrx 1';
      my $match = $/.new($/);
      for @subregexes -> &rx {
        say 'subrx 2';
        my $submatch = $/.new($/);
        say $/.perl;
        say 'subrx 3';
        my $result = rx($submatch);
        say 'subrx 4';
        if $result {
           say 'subrx 4.1';
           $match = $result;
           say 'subrx 4.2';
        };
        say 'subrx 5';
      };
      say 'subrx 6';
      make $match;
      say 'subrx 7';
    }

    $!regex = token { $<action> = <subrx> };

    # I get a null pmc in isa_pmc() if without this line...
    1;
  }

  method dispatch() {
    self.compile;
# rakudo does not support contextual variables yet
#    if $*request.uri.path ~~ $!regex {
say 'before';
    if '/blog/faz' ~~ $!regex {
say 'after';
      self.run-action($<action><?>, |$<action><actcap>);
    } else {
      fail 'No action matched';
    }
  }

  method run-action($action, *@_, *%_) {
    my $errors is context<rw>;
    try {
      $action.*begin;
      $action.*execute(|@_, |%_);
      CATCH {
        $_.handled = 1;
        $errors = $_;
      }
    }
    $action.*end;
# we don't know how to handle control exceptions yet.
#    CONTROL {
#      when Faz::ControlExceptionDetach {
#        self.run-action(%!actions{$_.path}, |$_.capture);
#      }
#    }
  }
}
