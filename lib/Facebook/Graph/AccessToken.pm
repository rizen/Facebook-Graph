use strict;
use warnings;
package Facebook::Graph::AccessToken;

use Moose;
use Facebook::Graph::AccessToken::Ressponse;
use Facebook::Graph::Uri;
use LWP::UserAgent;

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

has code => (
    is      => 'ro',
    required=> 1,
);

sub to_url {
    my ($self) = @_;
    return Facebook::Graph::Uri->new
        ->path('/oauth/access_token')
        ->query_form(
            client_id       => $self->app_id,
            client_secret   => $self->secret,
            redirect_uri    => $self->redirect_uri,
            code            => $self->code,
        )
        ->as_string;
}

sub fetch_token {
    my ($self) = @_;
    my $response = LWP::UserAgent->new->get($self->to_url);
    return Facebook::Graph::AccessToken::Response->new($response);
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
