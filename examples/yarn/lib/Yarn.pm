use Web::Request;
use Web::Response;
use Faz::Application;
use Faz::Dispatcher;
use Faz::Action::Root;
use Faz::Action::Chained;
use Faz::Action::Public;
use Tags;

class Yarn is Faz::Application {

  method setup {
    $.dispatcher = Faz::Dispatcher.new;

    my $root = Faz::Action::Chained.new\
      ( :parent(False),
        :regex(/^ /),
        :private-name('root'),
        :begin-closure({
          %*stash<posts> = 'data/posts' ~~ :f
                        ?? @(eval(slurp('data/posts')))
                        !! ();
        }),
        :finish-closure({
          unless 'data' ~~ :d {
            run('mkdir data');
          }
          my $fh = open('data/posts', :w) or die $!;
          $fh.print( %*stash<posts>.perl );
          $fh.close;
        })
      );
    self.register-action($root);

    my $index = Faz::Action::Public.new\
      ( :private-name('index'),
        :regex(/ \/ $ /),
        :parent($root),
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
      ( :private-name('create'),
        :regex(/ \/create \/? $/),
        :parent($root),
        :execute-closure({
           when $*request.GET<title> ne '' {
             my $p = $*request.GET;
             %*stash<posts>.unshift( { title => $p<title>,
                                       content => $p<content>,
                                       comments => [] } );
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
      ( :private-name('post'),
        :regex(/ \/ (\d+) /),
        :parent($root),
        :begin-closure( -> $post_id {
           %*stash<post_id> = $post_id;
           %*stash<post> = %*stash<posts>[$post_id];
        })
      );
    self.register-action($post);

    my $view_post = Faz::Action::Public.new\
      ( :private-name('view'),
        :regex(/ \/? $ /),
        :parent($post),
        :execute-closure({
           $*response.write(show {
             html {
               head { title { 'Yarn' } }
                 body {
                   div :class<post>, {
                     h1 { %*stash<post><title> };
                     div { %*stash<post><content> };
                     div :class<comments>, {
                     for @(%*stash<post><comments>) -> $comment {
                       div :class<comment>, {
                         h2 { $comment<author> };
                         div { $comment<comment> };
                       }
                     }
                   }
                 }
               }
             }
           });
        })
      );
    self.register-action($view_post);

    my $write_comment = Faz::Action::Public.new\
      ( :private-name('comment'),
        :regex(/ \/comment \/? $/),
        :parent($post),
        :execute-closure({
           when $*request.GET<author> ne '' {
             my $p = $*request.GET;
             %*stash<post><comments>.unshift( { author => $p<author>,
                                                comment => $p<comment> } );
           }

           $*response.write(show {
             html { title { 'Write a comment' } }
               body {
                 form :action('/'~%*stash<post_id>~'/comment'), :method<get>, {
                   p { input :name<author>, { '' } }
                   p { textarea :name<comment>, { '' } }
                   p { input :type<submit>, { '' } }
                 }
               }
           });
        })
      );
    self.register-action($write_comment);

    $.dispatcher.compile;
  }

  method call($env) {
    my Web::Request $req .= new($env);
    my Web::Response $res .= new;
    self.handle($req, $res);
    $res.finish();
  }
}
