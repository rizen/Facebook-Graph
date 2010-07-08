use strict;
use warnings;
package Facebook::Graph::AccessToken::Response;

use Moose;
use URI;
use URI::QueryParam;

has response => (
    is      => 'ro',
    required=> 1,
);

has token => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            return URI->new($response->content)->query_param('access_token');
        }
        else {
            confess [$response->code, 'Could not fetch access token: '.$response->message]
        }
    }
);

has expires => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            return URI->new($response->content)->query_param('expires');
        }
        else {
            confess [$response->code, 'Could not fetch access token: '.$response->message]
        }
    }
);


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
