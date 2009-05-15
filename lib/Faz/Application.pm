use Faz::Dispatcher;
use Faz::Container;
role Faz::Application {
  has Faz::Dispatcher $.dispatcher is rw handles <register-action dispatch>;
  has Faz::Container $.container is rw handles <register-component component model view>;

  # this is where the several steps performed by catalyst should
  # reside, so application-wide plugins can modify
  multi method prepare { };
  multi method finalize { };

  multi method handle($request? is context = $*request,
                      $response? is context = $*response) {
     my $app is context = self;
     # TODO: context vars are still globals in rakudo...
     $*app = self;
     $*request = $request;
     $*response = $response;
     %*stash = ();
     self.*prepare;
     self.*dispatch;
     self.*finalize;
  };

}
