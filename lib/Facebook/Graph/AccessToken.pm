package Facebook::Graph::AccessToken;

use Moo;
use Facebook::Graph::AccessToken::Response;
use Facebook::Graph::Request;
with 'Facebook::Graph::Role::Uri';

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
    required=> 0,
    predicate=> 'has_code',
);

has access_token => (
	is => 'ro',
	required => 0,
	predicate => 'has_access_token',
);

sub BUILD { 
	my $self = shift;
	die "Either code or access_token is required" if not $self->has_code and not $self->has_access_token;
}

sub uri_as_string {
    my ($self) = @_;
    my $uri = $self->uri;
    $uri->path('oauth/access_token');

	if($self->has_code) {
		$uri->query_form(
			client_id       => $self->app_id,
			client_secret   => $self->secret,
			redirect_uri    => $self->postback,
			code            => $self->code,
		);
	}
	else { 
		$uri->query_form(
			grant_type 			=> 'fb_exchange_token',
			client_id       	=> $self->app_id,
			client_secret   	=> $self->secret,
			redirect_uri    	=> $self->postback,
			fb_exchange_token	=> $self->access_token,
		);
	}

    return $uri->as_string;
}

sub request {
    my ($self) = @_;
    return Facebook::Graph::AccessToken::Response->new(
        response => Facebook::Graph::Request->new->get($self->uri_as_string)->recv->response
    );
}

1;

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

=head2 new ( [ params ] )

=over

=item params

A hash or hashref of parameters to pass to the constructor.

=over

=item app_id

The application id that you get from Facebook after registering (L<http://developers.facebook.com/setup/>) your application on their site. Required if you'll be calling the C<request_access_token>, C<convert_sessions>, or C<authorize> methods.

=item code

An authorization code string that you should have gotten by going through the C<authorize> process.

=item postback

The URI that Facebook should post your authorization code back to. Required if you'll be calling the C<request_access_token> or C<authorize> methods.

=item secret

The application secret that you get from Facebook after registering your application. Required if you'll be calling the C<request_access_token> or C<convert_sessions> methods.

=head2 uri_as_string ()

Returns the URI that will be called to fetch the token as a string. Mostly useful for debugging and testing.

=head2 request ()

Makes a request to Facebook to fetch an access token. Returns a L<Facebook::Graph::AccessToken::Response> object.

=head2 build ()

Checks for either access_token or code and dies if has neither.

=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2012 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
