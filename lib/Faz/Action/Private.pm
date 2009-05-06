class Faz::Action::Private does Faz::Action {
   has Callable $.begin-closure;
   has Callable $.execute-closure;
   has Callable $.finish-closure;
   multi method begin(*@p, *%n) {
     $.begin-closure.(|@p, |%n)
       if $.begin-closure;
   }
   multi method execute(*@p, *%n) {
     $.execute-closure.(|@p, |%n)
       if $.execute-closure;
   }
   multi method finish(*@p, *%n) {
     $.finish-closure.(@p, %n)
       if $.finish-closure;
   }
}
