package Facebook::Graph::Session;

use Any::Moose;
use Facebook::Graph::Response;
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

has sessions => (
    is      => 'ro',
    required=> 1,
);

sub uri_as_string {
    my ($self) = @_;
    my $uri = $self->uri;
    $uri->path('oauth/access_token');
    $uri->query_form(
        type            => 'client_cred',
        client_id       => $self->app_id,
        client_secret   => $self->secret,
        sessions        => join(',', @{$self->sessions})
    );
    return $uri->as_string;
}

sub request {
    my ($self) = @_;
    my $response = LWP::UserAgent->new->get($self->uri_as_string);
    return Facebook::Graph::Response->new(response => $response);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Session - Convert old API sessions into Graph API access_tokens.


=head1 SYNOPSIS

 my $fb = Facebook::Graph->new(
    secret      => $facebook_application_secret,
    app_id      => $facebook_application_id,
    postback    => 'https://www.yourapplication.com/facebook/postback',
 );
 my $tokens = $fb->session(\@session_ids)->request->as_hashref;

=head1 DESCRIPTION

Allows you to request convert your old sessions into access tokens.

B<NOTE:> If you're writing your application from scratch using L<Facebook::Graph> then you'll never need this module.

=head1 METHODS

=head2 uri_as_string ()

Returns the URI that will be called to fetch the token as a string. Mostly useful for debugging and testing.

=head2 request ()

Makes a request to Facebook to fetch an access token. Returns a L<Facebook::Graph::Response> object. Example JSON response:

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut