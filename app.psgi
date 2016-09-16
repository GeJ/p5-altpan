use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";
use File::Basename;
use File::Path qw(make_path);
use File::Spec;
use Plack::App::Directory;
use Plack::Builder;
use AltPAN::Web;

my $root_dir = File::Basename::dirname(__FILE__);
my $dist_dir = $ENV{ALTPAN_DISTDIR} // File::Spec->catdir($root_dir, 'altpan');

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
        $app;
    };
};

