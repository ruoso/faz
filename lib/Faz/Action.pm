# this is a normal private action
use Faz::Controller;
role Faz::Action {
   has Faz::Controller $.controller;
   has Str $.private-name;
   multi method begin {...}
   multi method execute(*@_, *%_) {...}
   multi method end {...}
}
