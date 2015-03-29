package Facebook::Graph::AccessToken::Response;

use Moo;
use URI;
use URI::QueryParam;
use Ouch;
use JSON;

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
            if ($response->content =~ m/\A { .+ } \z/xm) {
                # From v2.3 they return JSON object.
                return JSON->new->decode($response->content)->{access_token};
            }
            else {
                return URI->new('?'.$response->content)->query_param('access_token');
            }
        }
        else {
            ouch $response->code, 'Could not fetch access token: '._retrieve_error_message($response), $response->request->uri->as_string;
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
            if ($response->content =~ m/\A { .+ } \z/xm) {
                # From v2.3 they return JSON object.
                return JSON->new->decode($response->content)->{expires_in};
            }
            else {
                return URI->new('?'.$response->content)->query_param('expires');
            }
        }
        else {
            ouch $response->code, 'Could not fetch access token: '._retrieve_error_message($response), $response->request->uri->as_string;
        }
    }
);

sub _retrieve_error_message {
    my $response = shift;
    my $content = eval { from_json($response->decoded_content) };
    if ($@) {
        return $response->message;
    }
    else {
        return $content->{error}{message};
    }
}

1;

=head1 NAME

Facebook::Graph::AccessToken::Response - The Facebook access token request response.

=head1 Description

You'll be given one of these as a result of calling the C<request> method from a L<Facebook::Graph::AccessToken> object.

=head1 METHODS

=head2 token ()

Returns the token string.

=head2 expires ()

Returns the time allotted to this token. If undefined then the token is forever.

=head2 response ()

Direct access to the L<HTTP::Response> object.

=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2012 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


