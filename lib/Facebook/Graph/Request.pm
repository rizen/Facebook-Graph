package Facebook::Graph::Request;

use Any::Moose;
use JSON;
use Ouch;
use AnyEvent::HTTP::LWP::UserAgent;
use AnyEvent;
use Facebook::Graph::Response;

has ua => (
    is      => 'rw',
    isa     => 'AnyEvent::HTTP::LWP::UserAgent',
    lazy    => 1,
    default => sub {
        my $ua = AnyEvent::HTTP::LWP::UserAgent->new;
        $ua->timeout(30);
        return $ua;
    },
);

sub post {
    my ($self, $uri, $params) = @_;
    my $cv = AnyEvent->condvar;
    $self->ua->post_async($uri, $params)->cb(sub {
        $cv->send(Facebook::Graph::Response->new(response => shift->recv));
    });
    return $cv;
}

sub get {
    my ($self, $uri) = @_;
    my $ua = $self->ua;
    my $cv = AnyEvent->condvar;
    $ua->get_async($uri)->cb(sub {
        $cv->send(Facebook::Graph::Response->new(response => shift->recv));
    });
    return $cv;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

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

An L<AnyEvent::HTTP::LWP::UserAgent> object. It will be created for you if you don't pass one in.

=back

=back

=head2 post ( uri, params )

A POST request will be made.

=over

=item uri

A URI string to Facebook.

=item headers

A hash of headers to pass to L<AnyEvent::HTTP::LWP::UserAgent> when making the request.

=back


=head2 get ( uri, params )

A GET request will be made.

=over

=item uri

A URI to fetch.

=back



=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2012 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


