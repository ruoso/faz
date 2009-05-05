module MyApp;

use Faz::Application;
use Faz::Controller;
use Faz::Action::Root;
use Faz::Action::Chained;
use Faz::Action::Public;

my $app = Faz::Application.new(:dispatcher(Faz::Dispatcher.new()));
my $ctrl = Faz::Controller.new();

my $root = Faz::Action::Root.new( :controller($ctrl),
                                  :private-name('(root)/'),
                                  :base('http://localhost/'),
                                  :begin-closure({ say "root - begin" }),
                                  :execute-closure({ say "root - execute " }),
                                  :end-closure({ say "root - end" }) );
$app.register-action($root);

my $blog = Faz::Action::Chained.new( :controller($ctrl),
                                     :private-name('(root)/blog/*'),
                                     :regex(/ blog\/(\w+) /),
                                     :begin-closure({ say "blog - begin" }),
                                     :execute-closure(-> $name { say "blog($name) - execute " }),
                                     :end-closure({ say "blog - end" }) );
$app.register-action($blog);

my $viewblog = Faz::Action::Public.new( :controller($ctrl),
                                        :private-name('(root)/blog/*/'),
                                        :regex(/^ $/),
                                        :begin-closure({ say "viewblog - begin" }),
                                        :execute-closure({ say "viewblog - execute" }),
                                        :end-closure({ say "viewblog - end" }) );
$app.register-action($viewblog);

