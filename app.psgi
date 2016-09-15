use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";
use File::Basename;
use Plack::App::Directory;
use Plack::Builder;
use AltPAN::Web;

my $root_dir = File::Basename::dirname(__FILE__);

my $app = AltPAN::Web->psgi($root_dir);
builder {
    mount '/altpan' => Plack::App::Directory->new({root => $root_dir . '/altpan'})->to_app;
    mount '/' => sub {
        enable 'ReverseProxy';
        enable 'Static',
            path => qr!^/(?:(?:css|fonts|js)/|favicon\.ico$)!,
            root => $root_dir . '/public';
        $app;
    };
};

