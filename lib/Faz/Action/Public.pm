# this is an action that is seen as an endpoint
use Faz::Action::Chained;
role Faz::Action::Public does Faz::Action::Chained {
   has Int $.priority;
}
