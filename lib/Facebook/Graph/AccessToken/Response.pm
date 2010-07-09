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
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph::AccessToken::Respponse - The Facebook access token request response.


=head1 METHODS

=head2 token ()

Returns the token string.

=head2 expires ()

Returns the time alotted to this token. If undefined then the token is forever.

=head2 response ()

Direct access to the L<HTTP::Response> object.

=cut


