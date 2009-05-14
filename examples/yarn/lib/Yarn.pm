use Web::Request;
use Web::Response;
use Faz::Application;
use Faz::Dispatcher;
use Faz::Action::Root;
use Faz::Action::Chained;
use Faz::Action::Public;
use Tags;

class Yarn is Faz::Application {
  my sub get-posts() {
    my @posts = 'data/posts' ~~ :f
      ?? @(eval(slurp('data/posts')))
        !! ();
    return @posts;
  }

  method setup {
    $.dispatcher = Faz::Dispatcher.new;

    my $root = Faz::Action::Chained.new\
      ( :parent(0),
        :private-name('(root)'),
        :regex(/ ^ /),
        :execute-closure({ 1; }),
        :finish-closure({ 1; }),
        :begin-closure({ %*stash<posts> = get-posts() }) );
    self.register-action($root);

    my $index = Faz::Action::Public.new\
      ( :private-name('(root)/'),
        :regex(/ \/ $ /),
        :parent($root),
        :begin-closure({ 1; }),
        :finish-closure({ 1; }),
        :execute-closure({
           $*response.write(show {
             html {
               head { title { 'Yarn' } }
                 body {
                   p {
                     a :href</create>, { 'Write a new post' }
                     }
                     for @(%*stash<posts>) -> $post {
                       div :class<post>, {
                         h1 { $post<title> };
                         div { $post<content> };
                       }
                     }
                   }
                 }
               })
        })
      );
    self.register-action($index);

    my $create = Faz::Action::Public.new\
      ( :private-name('(root)/create'),
        :regex(/ \/create \/? $/),
        :parent($root),
        :begin-closure({ 1; }),
        :finish-closure({ 1; }),
        :execute-closure({
           when $*request.GET<title> ne '' {
             my $p = $*request.GET;
             unless 'data' ~~ :d {
               run('mkdir data');
             }
             %*stash<posts>.unshift( { title => $p<title>,
                                       content => $p<content> } );
             my $fh = open('data/posts', :w) or die $!;
             $fh.print( %*stash<posts>.perl );
             $fh.close;
           }

           $*response.write(show {
             html { title { 'Writing a post' } }
               body {
                 form :action</create>, :method<get>, {
                   p { input :name<title>, { '' } }
                   p { textarea :name<content>, { '' } }
                   p { input :type<submit>, { '' } }
                 }
               }
           });
        })
      );
    self.register-action($create);

    my $post = Faz::Action::Chained.new\
      ( :private-name('(root)/*'),
        :regex(/ \/ (\d+) /),
        :parent($root),
        :finish-closure({ 1; }),
        :execute-closure({ 1; }),
        :begin-closure( -> $post_id {
           %*stash<post> = %*stash<posts>[$post_id];
        })
      );
    self.register-action($post);

    my $view_post = Faz::Action::Public.new\
      ( :private-name('(root)/*/'),
        :regex(/ \/? $ /),
        :parent($post),
        :finish-closure({ 1; }),
        :begin-closure({ 1; }),
        :execute-closure({
           $*response.write(show {
             html {
               head { title { 'Yarn' } }
                 body {
                   div :class<post>, {
                     h1 { %*stash<post><title> };
                     div { %*stash<post><content> };
                   }
                 }
               }
           });
        })
      );
    self.register-action($view_post);

    $.dispatcher.compile;
  }

  method call($env) {
    my Web::Request $req .= new($env);
    my Web::Response $res .= new;
    self.handle($req, $res);
    $res.finish();
  }
}
