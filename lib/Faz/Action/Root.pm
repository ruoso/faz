# this is used to mask out the base-uri for the application
use Faz::Action::Chained;
class Faz::Action::Root is Faz::Action::Chained {
   has $.base;
   method parent {
     False
   }
   method private-name {
     'root';
   }
   method regex {
     /^  /;
   }
}
