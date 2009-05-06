use Faz::Action;
class Faz::Action::Chained does Faz::Action {
   has Faz::Action::Chained $.parent;
   has Regex $.regex;

   has Callable $.begin-closure;
   has Callable $.execute-closure;
   has Callable $.end-closure;

   multi method begin(*@_, :$parent_action_capture, *%_) {
     if $.parent {
       my %named;
       my @pos;
       if $parent_action_capture {
         %named := %($parent_action_capture<action_capture>);
         @pos := @($parent_action_capture<action_capture>);
         %named<parent_action_capture> = $parent_action_capture<parent_action_capture>;
         say 'named arguments are: ' ~ named;
       }
       $.parent.*begin(|@pos, |%named);
     }
     if $.begin-closure {
       $.begin-closure.(|@_, |%_)
     }
   }

   multi method execute(*@_, :$parent_action_capture, *%_) {
     if $.parent {
       my %named;
       my @pos;
       if $parent_action_capture {
         %named := %($parent_action_capture<action_capture>);
         @pos := @($parent_action_capture<action_capture>);
         %named<parent_action_capture> = $parent_action_capture<parent_action_capture>;
       }
       $.parent.*execute(|%named, |@pos);
     }
     if $.execute-closure {
       $.execute-closure.(|@_, |%_)
     }
   }

   multi method end(*@_, :$parent_action_capture, *%_) {
     if $.end-closure {
       $.end-closure.(|@_, |%_)
     }
     if $.parent {
       my %named;
       my @pos;
       if $parent_action_capture {
         %named := %($parent_action_capture<action_capture>);
         @pos := @($parent_action_capture<action_capture>);
         %named<parent_action_capture> = $parent_action_capture<parent_action_capture>;
       }
       $.parent.*end(|%named, |@pos);
     }
   }
}
