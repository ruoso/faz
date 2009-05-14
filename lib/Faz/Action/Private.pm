class Faz::Action::Private does Faz::Action {
   has $.begin-closure;
   has $.execute-closure;
   has $.finish-closure;
   multi method begin(*@p, *%n) {
     $.begin-closure.(|@p, |%n)
       if defined $.begin-closure;
   }
   multi method execute(*@p, *%n) {
     $.execute-closure.(|@p, |%n)
       if defined $.execute-closure;
   }
   multi method finish(*@p, *%n) {
     $.finish-closure.(@p, %n)
       if defined $.finish-closure;
   }
}
