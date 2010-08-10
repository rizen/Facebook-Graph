package Facebook::Graph::Response;

use Any::Moose;
use JSON;
use Digest::SHA qw(hmac_sha256);
use MIME::Base64::URLSafe;

has response => (
    is      => 'ro',
    required=> 1,
);

has secret => (
    is          => 'ro',
    required    => 0,
    predicate   => 'has_secret',
);

sub parse_signed_request {
    my ($self, $signed_request) = @_;

    my ($encoded_sig, $payload) = split(/\./, $signed_request);

	my $sig = urlsafe_b64decode($encoded_sig);
    my $data = decode_json(urlsafe_b64decode($payload));

    if (uc($data->{'algorithm'}) ne "HMAC-SHA256") {
        print "Unknown algorithm. Expected HMAC-SHA256";
        return -1;
    }

    my $expected_sig = hmac_sha256($payload, $self->secret);
    if ($sig ne $expected_sig) {
        print "Bad Signed JSON signature!";
        return -1;
    }
    return $data;
}

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
            my $type = 'Unkown';
            unless ($@) {
                $message = $error->{error}{type} . ' - ' . $error->{error}{message};
                $type = $error->{error}{type};
            }
            confess [$response->code, 'Could not execute request ('.$response->request->uri->as_string.'): '.$message, $type];
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

=head2 as_json ()

Returns the response from Facebook as a JSON string.

=head2 as_hashref ()

Returns the response from Facebook as a hash reference.

=head2 response ()

Direct access to the L<HTTP::Response> object.

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


