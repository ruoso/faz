use v6;
use HTTP::Daemon;
use Yarn;

my $yarn = Yarn.new;
$yarn.setup;

defined @*ARGS[0] && @*ARGS[0] eq '--request' ?? request() !! daemon();


# Serve one page
sub request($c) {
    my $r = $c.get_request;
    warn "{hhmm} {$r.req_method} {$r.url.path} {$r.header('User-Agent')}";
    if $r.req_method eq 'GET' {
        $r.url.path ~~ /^ (<-[?]>*) [ '?' (.*) ]? $/;
        $c.send_response(
            ~([~] $yarn.call({"QUERY_STRING" => $/[1],
                              "SCRIPT_NAME" => $/[0]}).[2])
        );
    }
    elsif $r.req_method eq 'POST' {
        $r.url.path ~~ /^ (<-[?]>*) [ '?' (.*) ]? $/;
        $c.send_response(
            ~([~] $yarn.call({"REQUEST_METHOD" => 'POST',
                             "QUERY_STRING" => $/[1],
                              "SCRIPT_NAME" => $/[0]}).[2])
        );
    }
    else {
        warn "{hhmm} rejected {$r.req_method} {$r.url.path}";
        $c.send_error('RC_FORBIDDEN');
    }
    warn ' '; # blank line
}

# Executed as main parent process with an endless loop that re-starts
# netcat after every page request.
sub daemon {
    my HTTP::Daemon $d .= new( host=> '127.0.0.1', port=> 8765 );
    say "Browse this Perl 6 (Rakudo) web server at {$d.url}";
    $d.daemon();
}

# give the current time in hh:mm format
sub hhmm {
    my $t = int(time);
    my $m = int( $t / 60 ) % 60;
    my $h = int( $t / 3600 ) % 24;
    my $hhmm = "{$h.fmt('%02d')}:{$m.fmt('%02d')}";
    return $hhmm;
}
