module MyApp;

use Faz::Application;

my $app = Faz::Application.new();
$app.dispatcher = Faz::Dispatcher.new();
my $ctrl = Faz::Controller.new();

my $root = Faz::Action::Root.new( :private-name('(root)/'),
                                  :base('http://localhost/'),
                                  :begin-closure({ say "root - begin" }),
                                  :execute-closure({ say "root - execute " }),
                                  :end-closure({ say "root - end" }) );
$app.register-action($root);

my $blog = Faz::Action::Chained.new( :private-name('(root)/blog/*'),
                                     :regex(/ blog\/(\w+) /),
                                     :begin-closure({ say "blog - begin" }),
                                     :execute-closure(-> $name { say "blog($name) - execute " }),
                                     :end-closure({ say "blog - end" }) );
$app.register-action($blog);

my $viewblog = Faz::Action::Public.new( :private-name('(root)/blog/*/'),
                                        :regex(/^ $/),
                                        :begin-closure({ say "viewblog - begin" }),
                                        :execute-closure({ say "viewblog - execute" }),
                                        :end-closure({ say "viewblog - end" }) );
$app.register-action($viewblog);

