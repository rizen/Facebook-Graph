package Facebook::Graph::Request;

use Moo;
use JSON;
use Ouch;
use LWP::UserAgent;
use LWP::Protocol::https;
use Facebook::Graph::Response;

has ua => (
    is      => 'rw',
    isa     => sub {ouch(442,"$_[0] is not an LWP::UserAgent object") unless ref $_[0] eq 'LWP::UserAgent'},
    lazy    => 1,
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->timeout(30);
        return $ua;
    },
);

sub post {
    my ($self, $uri, @params) = @_;
    return Facebook::Graph::Response->new(response => $self->ua->post($uri, @params));
}

sub get {
    my ($self, $uri) = @_;
    return Facebook::Graph::Response->new(response => $self->ua->get($uri));
}

1;

=head1 NAME

Facebook::Graph::Request - Handling posts to Facebook Graph.

=head1 DESCRIPTION

This is the standard interface to the Facebook Graph API that all other modules use.

=head1 METHODS

=head2 new(params)

=over

=item params

A hash or hashref of parameters to pass to the constructor.

=over

=item ua

An L<LWP::UserAgent> object. It will be created for you if you don't pass one in.

=back

=back

=head2 post ( uri, params )

A POST request will be made.

=over

=item uri

A URI string to Facebook.

=item headers

A hash of headers to pass to L<LWP::UserAgent> when making the request.

=back


=head2 get ( uri, params )

A GET request will be made.

=over

=item uri

A URI to fetch.

=back



=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2017 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


