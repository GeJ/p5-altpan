package AltPAN::Web;

use 5.010001;
use strict;
use warnings;
use utf8;
use Kossy;

use File::Copy ();
use File::Spec;
use File::Temp ();
use OrePAN2::Indexer;
use OrePAN2::Injector;
use Try::Tiny;

sub dist_dir { # {{{
    my $self = shift;
    state $dist_dir ||= do {
        my $dir = $ENV{ALTPAN_DISTDIR} // File::Spec->catdir($self->root_dir, 'altpan');
        Carp::croak("Distribution repository does not exist")
            unless (-d $dir);
        $dir;
    };
} # }}}

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

post '/authenquery' => sub { # {{{
    my ($self, $c) = @_;

    try {
        my ($module, $author);
        my $tempdir = File::Temp::tempdir(CLEANUP => 1);
        if (my $upload = $c->req->('pause99_add_uri_httpupload')) {
            $module = File::Spec->catfile($tempdir, $upload->filename);
            File::Copy::move $upload->tempname, $module;
            $author = $c->req->param('HIDDENNAME');
        }
        else {
            $module = $c->req->param('module');
            $author = $c->req->param('author') || 'DUMMY';
        }
        $c->halt(404) unless ($module && $author);
        $author = uc $author;

        my $injector = OrePAN2::Injector->new(
                directory => $self->dist_dir,
                author    => $author,
            );
        $injector->inject($module);
        OrePAN2::Indexer->new(directory => $self->dist_dir)
            ->make_index();
    }
    catch {
        if (ref $_ && (ref $_ eq 'Kossy::Exception')) {
            # Rethrow
            die $_;
        }
        else {
            $c->halt(500, $_);
        }
    };

    $c->res->status(200);
    $c->res->content_type('text/plain; charset=UTF-8');
    $c->res->body('OK');
    return $c->res;
}; # }}}

1;

