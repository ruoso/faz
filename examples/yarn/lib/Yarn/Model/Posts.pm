class Yarn::Model::Posts does Faz::Component {
  my @posts = 'data/posts' ~~ :f
    ?? @(eval(slurp('data/posts')))
      !! ();

  method save {
    unless 'data' ~~ :d {
      run('mkdir data');
    }
    my $fh = open('data/posts', :w) or die $!;
    $fh.print( @posts.perl );
    $fh.close;
  }

  method unshift(*@_) {
    @posts.unshift(|@_);
  }

  method postcircumfix:<[ ]>(*@_) {
    @posts[|@_];
  }

}
