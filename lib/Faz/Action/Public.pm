# this is an action that is seen as an endpoint
use Faz::Action::Chained;
class Faz::Action::Public is Faz::Action::Chained {
   has Int $.priority;
}
