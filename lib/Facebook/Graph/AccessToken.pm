package Facebook::Graph::AccessToken;

use Any::Moose;
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

has ua => (
    is => 'rw',
);

sub uri_as_string {
    my ($self) = @_;
    my $uri = $self->uri;
    $uri->path('oauth/access_token');
    $uri->query_form(
        client_id       => $self->app_id,
        client_secret   => $self->secret,
        redirect_uri    => $self->postback,
        code            => $self->code,
    );
    return $uri->as_string;
}

sub request {
    my ($self) = @_;
    my $response = ($self->ua || LWP::UserAgent->new)->get($self->uri_as_string);
    return Facebook::Graph::AccessToken::Response->new(response => $response);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::AccessToken - Acquire an access token from Facebook.


=head1 SYNOPSIS

 my $fb = Facebook::Graph->new(
    secret      => $facebook_application_secret,
    app_id      => $facebook_application_id,
    postback    => 'https://www.yourapplication.com/facebook/postback',
 );
 my $token_response_object = $fb->request_access_token($code_from_authorize_postback);

 my $token_string = $token_response_object->token;
 my $token_expires_epoch = $token_response_object->expires;

=head1 DESCRIPTION

Allows you to request an access token from Facebook so you can make privileged requests on the Graph API.

=head1 METHODS

=head2 uri_as_string ()

Returns the URI that will be called to fetch the token as a string. Mostly useful for debugging and testing.

=head2 request ()

Makes a request to Facebook to fetch an access token. Returns a L<Facebook::Graph::AccessToken::Response> object.

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
