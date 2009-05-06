# this is a normal private action
use Faz::Controller;
role Faz::Action {
   has Faz::Controller $.controller;
   has Str $.private-name;
# TODO: yada methods are not supported yet
#   multi method begin(*@p, *%n) {...}
#   multi method execute(*@p, *%n) {...}
#   multi method finish(*@p, *%n) {...}
}
