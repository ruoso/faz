use Faz::Action;
class Faz::Action::Chained does Faz::Action {
   has Faz::Action::Chained $.parent;
   has Regex $.regex;

   has Callable $.begin-closure;
   has Callable $.execute-closure;
   has Callable $.end-closure;

   multi method begin {
     $.parent.*begin
       if $.parent;
     $.begin-closure.(self)
       if $.begin-closure;
   }

   multi method execute(*@_, :$_parent_action_capture, *%_) {
     $.parent.*execute(|$_parent_action_capture);
       if $.parent;
     $.execute-closure.(self, |@_, |%_)
       if $.execute-closure;
   }

   multi method end {
     $.parent.*end
       if $.parent;
     $.end-closure.(self)
       if $.end-closure;
   }
}
