package AltPAN::Web;

use strict;
use warnings;
use utf8;
use Kossy;

use File::Copy ();
use File::Spec;
use File::Temp ();
use OrePAN2::Indexer;
use OrePAN2::Injector;

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

get '/' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    $c->render('index.tx', { greeting => "Hello" });
};

post '/authenquery' => sub {
    my ($self, $c) = @_;

    my ($module, $author);
    my $tempdir = File::Temp::tempdir(CLEANUP => 1);
    if (my $upload = $c->req->('pause99_add_uri_httpupload')) {
        $module = File::Spec->catfile($tempdir, $upload->filename);
        File::Copy::move $upload->tempname, $module;
        $author = $req->param('HIDDENNAME');
    }
    else {
        $module = $req->param('module');
        $author = $req->param('author') || 'DUMMY';
    }
    $c->halt(404) if ($module && 

    my $injector = OrePAN2::Injector->new(
            directory => $directory,
            author    => $author,
        );
    $injector->inject($module);
    OrePAN2::Indexer->new(directory => $directory)
        ->make_index(no_compress => !$compress_index);
        }
};

1;

