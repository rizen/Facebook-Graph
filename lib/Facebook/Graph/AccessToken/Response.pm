package Facebook::Graph::AccessToken::Response;

use Any::Moose;
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
            return URI->new('?'.$response->content)->query_param('access_token');
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
            return URI->new('?'.$response->content)->query_param('expires');
        }
        else {
            confess [$response->code, 'Could not fetch access token: '.$response->message]
        }
    }
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph::AccessToken::Response - The Facebook access token request response.

=head1 Description

You'll be given one of these as a result of calling the C<request> method from a L<Facebook::Graph::AccessToken> object.

=head1 METHODS

=head2 token ()

Returns the token string.

=head2 expires ()

Returns the time alotted to this token. If undefined then the token is forever.

=head2 response ()

Direct access to the L<HTTP::Response> object.

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


