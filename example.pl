module MyApp;

use Faz::Request;
use Faz::URI;
use Faz::Application;
use Faz::Controller;
use Faz::Action::Root;
use Faz::Action::Chained;
use Faz::Action::Public;

my $app = Faz::Application.new(:dispatcher(Faz::Dispatcher.new()));
my $ctrl = Faz::Controller.new();

my $root = Faz::Action::Root.new( :parent(0),
                                  :controller($ctrl),
                                  :private-name('(root)'),
                                  :base('/'),
                                  :begin-closure({ say "root - begin" }),
                                  :execute-closure({ say "root - execute " }),
                                  :end-closure({ say "root - end" }) );
$app.register-action($root);

my $blog = Faz::Action::Chained.new( :parent($root),
                                     :controller($ctrl),
                                     :private-name('(root)/blog/*'),
                                     :regex(/ blog\/(\w+)\/ /),
                                     :begin-closure(-> $name { say "blog $name - begin " }),
                                     :execute-closure(-> $name { say "blog $name - execute " }),
                                     :end-closure(-> $name { say "blog $name - end" }) );
$app.register-action($blog);

my $viewblog = Faz::Action::Public.new( :parent($blog),
                                        :controller($ctrl),
                                        :private-name('(root)/blog/*/'),
                                        :regex(/ (\w+) \/? /),
                                        :begin-closure( -> $name { say "viewblog $name - begin" }),
                                        :execute-closure( -> $name { say "viewblog $name - execute" }),
                                        :end-closure(-> $name { say "viewblog $name - end" }) );
$app.register-action($viewblog);

my $uri = Faz::URI.new(:path('/blog/faz/bla'));
my $request is context = Faz::Request.new(:uri($uri));
my $response is context = 1;
$app.handle($request,$response);

1;
