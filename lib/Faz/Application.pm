use Faz::Dispatcher;
role Faz::Application {
  has %.components is rw;
  has Faz::Dispatcher $.dispatcher is rw handles <register-action dispatch>;

  # this is where the several steps performed by catalyst should
  # reside, so application-wide plugins can modify
  multi method prepare { };
  multi method finalize { };

  multi method handle($request? is context = $*request,
                      $response? is context = $*response) {
     my $application is context = self;
     # TODO: context vars are still globals in rakudo...
     $*application = self;
     $*request = $request;
     $*response = $response;
     %*stash = ();
     self.prepare;
     self.dispatch;
     self.finalize;
  };

}
