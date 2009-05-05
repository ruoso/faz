role Faz::Action::Private does Faz::Action {
   has Callable $.begin-closure;
   has Callable $.execute-closure;
   has Callable $.end-closure;
   multi method begin {
     $.begin-closure.(self)
       if $.begin-closure;
   }
   multi method execute(*@_, *%_) {
     $.execute-closure.(self, |@_, |%_)
       if $.execute-closure;
   }
   multi method end {
     $.end-closure.(self)
       if $.end-closure;
   }
}
