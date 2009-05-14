use Faz::Action;
class Faz::Action::Chained does Faz::Action {
   has Faz::Action::Chained $.parent;
   has Regex $.regex;

   has $.begin-closure;
   has $.execute-closure;
   has $.finish-closure;

   method private-name {
     my $name = '';
     if defined $.parent {
        $name = $.parent.private-name ~ '/';
     }
     $name ~= $!private-name;
   }

   multi method begin(*@p, :$parent_action_capture, *%n) {
     if $.parent {
       my %named;
       my @pos;
       if $parent_action_capture {
         %named := %($parent_action_capture<action_capture>);
         @pos := @($parent_action_capture<action_capture>);
         %named<parent_action_capture> = $parent_action_capture<parent_action_capture>;
       }
       $.parent.*begin(|@pos, |%named);
     }
     if defined $.begin-closure {
       $.begin-closure.(|@p, |%n)
     }
   }

   multi method execute(*@p, :$parent_action_capture, *%n) {
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
     if defined $.execute-closure {
       $.execute-closure.(|@p, |%n)
     }
   }

   multi method finish(*@p, :$parent_action_capture, *%n) {
     if defined $.finish-closure {
       $.finish-closure.(|@p, |%n)
     }
     if $.parent {
       my %named;
       my @pos;
       if $parent_action_capture {
         %named := %($parent_action_capture<action_capture>);
         @pos := @($parent_action_capture<action_capture>);
         %named<parent_action_capture> = $parent_action_capture<parent_action_capture>;
       }
       $.parent.*finish(|%named, |@pos);
     }
   }
}
