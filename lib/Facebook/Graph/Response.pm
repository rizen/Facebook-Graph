package Facebook::Graph::Response;

use Any::Moose;
use JSON;
use Facebook::Graph::Exception;

has response => (
    is      => 'ro',
    required=> 1,
);

has as_string => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->response->content;
    },
);

has as_json => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $response = $self->response;
        if ($response->is_success) {
            return $response->content;
        }
        else {
            my $message = $response->message;
            my $error = eval { JSON->new->decode($response->content) };
            my $type = 'Unknown';
            my $fberror = 'Unknown';
            unless ($@) {
                $fberror = $error->{error}{message};
                $message = $error->{error}{type} . ' - ' . $error->{error}{message};
                $type = $error->{error}{type};
            }
            Facebook::Graph::Exception::RPC->throw(
                error               => 'Could not execute request ('.$response->request->uri->as_string.'): '.$message,
                uri                 => $response->request->uri->as_string,
                http_code           => $response->code,
                http_message        => $response->message,
                facebook_message    => $fberror,
                facebook_type       => $type,
            );
        }
    },
);

has as_hashref => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return JSON->new->decode($self->as_json);
    },
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph::Response - Handling of a Facebook::Graph response documents.

=head1 DESCRIPTION

You'll be given one of these as a result of calling the C<request> method on a C<Facebook::Graph::Query> or others.


=head1 METHODS

Returns the response as a string. Does not throw an exception of any kind.

=head2 as_json ()

Returns the response from Facebook as a JSON string.

=head2 as_hashref ()

Returns the response from Facebook as a hash reference.

=head2 as_string ()

No processing what so ever. Just returns the raw body string that was received from Facebook.

=head2 response ()

Direct access to the L<HTTP::Response> object.

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


