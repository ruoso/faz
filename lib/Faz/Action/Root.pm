# this is used to mask out the base-uri for the application
use Faz::Action::Chained;
role Faz::Action::Root does Faz::Action::Chained {
   has $.base;
   method regex {
      return / ^ $.base /;
   }
}
