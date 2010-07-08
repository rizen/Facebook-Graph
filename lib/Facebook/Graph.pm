use strict;
use warnings;
package Facebook::Graph;

use Moose;
use Facebook::Graph::AccessToken;
use Facebook::Graph::Authorize;

has app_id => (
    is      => 'ro',
    required=> 1,
);

has secret => (
    is      => 'ro',
    required=> 1,
);

has redirect_uri => (
    is      => 'ro',
    required=> 1,
);

sub access_token {
    my ($self, $code) = @_;
    return Facebook::Graph::AccessToken->new(
        code            => $code,
        redirect_uri    => $self->redirect_uri,
        secret          => $self->secret,
        app_id          => $self->app_id,
    );
}

sub authorize { 
    my ($self) = @_;
    return Facebook::Graph::Authorize->new(
        app_id          => $self->app_id,
        redirect_uri    => $self->redirect_uri,
    );
}


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

=head1 NAME

Facebook::Graph - An interface to the Facebook Graph API.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new(
    app_id          => $facebook_application_id,
    secret          => $facebook_application_secret,
    redirect_uri    => $the_url_where_facebook_posts_back_to_your_applicaiton,
 );


