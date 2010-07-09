package Facebook::Graph::Query::Response;

use Moose;
use JSON;

has response => (
    is      => 'ro',
    required=> 1,
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
            confess [$response->code, 'Could not execute query: '.$response->message]
        }
    }
);

has as_hashref => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return JSON->new->decode($self->as_json);
    }
);

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph::Query:Response - Handling of a Facebook::Graph::Query result set.


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


