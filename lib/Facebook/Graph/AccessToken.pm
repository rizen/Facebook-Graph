package Facebook::Graph::AccessToken;

use Moose;
use Facebook::Graph::AccessToken::Response;
with 'Facebook::Graph::Role::Uri';
use LWP::UserAgent;

has app_id => (
    is      => 'ro',
    required=> 1,
);

has secret => (
    is      => 'ro',
    required=> 1,
);

has postback => (
    is      => 'ro',
    required=> 1,
);

has code => (
    is      => 'ro',
    required=> 1,
);

sub uri_as_string {
    my ($self) = @_;
    return $self->uri
        ->path('oauth/access_token')
        ->query_form(
            client_id       => $self->app_id,
            client_secret   => $self->secret,
            redirect_uri    => $self->postback,
            code            => $self->code,
        )
        ->as_string;
}

sub request {
    my ($self) = @_;
    my $response = LWP::UserAgent->new->get($self->uri_as_string);
    return Facebook::Graph::AccessToken::Response->new($response);
}

no Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::AccessToken - Acquire and access token from Facebook.


=head1 METHODS

=head2 uri_as_string ()

=head2 request ()

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut