use Authen::Simple::Passwd;
use FindBin;
use File::Basename;
use File::Path qw(make_path);
use File::Spec;
use Plack::App::Directory;
use Plack::Builder;
use Plack::Builder::Conditionals;

use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";

use AltPAN::Web;

my $root_dir  = File::Basename::dirname(__FILE__);
my $dist_dir  = $ENV{ALTPAN_DISTDIR}  // File::Spec->catdir($root_dir, 'altpan');
my $auth_file = $ENV{ALTPAN_AUTHFILE} // File::Spec->catfile($root_dir, 'passwd');

unless (-d $dist_dir) {
    my $created_ok = make_path($dist_dir, {mode => 0755});
    die ("Cannot create distribution repository.")
        unless ($created_ok);
}

my $app = AltPAN::Web->psgi(root_dir => $root_dir, dist_dir => $dist_dir);
builder {
    mount '/altpan' => Plack::App::Directory->new({root => $dist_dir})->to_app;
    mount '/' => sub {
        enable 'ReverseProxy';
        enable 'Static',
            path => qr!^/(?:(?:css|fonts|js)/|favicon\.ico$)!,
            root => $root_dir . '/public';
	enable match_if (path(qr{^/authenquery$}) && method('POST')),
            'Plack::Middleware::Auth::Basic',
                authenticator => Authen::Simple::Passwd->new(path => $auth_file);
        $app;
    };
};

