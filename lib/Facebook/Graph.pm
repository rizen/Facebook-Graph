package Facebook::Graph;

use Moo;
use 5.006;
use MIME::Base64::URLSafe;
use JSON;
use Facebook::Graph::AccessToken;
use Facebook::Graph::Authorize;
use Facebook::Graph::Query;
use Facebook::Graph::Picture;
use Facebook::Graph::Request;
use Facebook::Graph::Publish::Post;
use Facebook::Graph::Publish::Photo;
use Facebook::Graph::Publish::Checkin;
use Facebook::Graph::Publish::Comment;
use Facebook::Graph::Publish::RSVPMaybe;
use Facebook::Graph::Publish::RSVPAttending;
use Facebook::Graph::Publish::RSVPDeclined;
use Facebook::Graph::Publish::PageTab;
use Facebook::Graph::BatchRequests;
use Facebook::Graph::Page::Feed;
use Ouch;

has app_id => (
    is      => 'ro',
);

has secret => (
    is          => 'ro',
    predicate   => 'has_secret',
);

has postback => (
    is      => 'rw',
);

has access_token => (
    is          => 'rw',
    predicate   => 'has_access_token',
);

sub parse_signed_request {
    my ($self, $signed_request) = @_;
    require Digest::SHA;
    my ($encoded_sig, $payload) = split(/\./, $signed_request);

	my $sig = urlsafe_b64decode($encoded_sig);
    my $data = JSON->new->decode(urlsafe_b64decode($payload));

    if (uc($data->{'algorithm'}) ne "HMAC-SHA256") {
        ouch '500', 'Unknown algorithm. Expected HMAC-SHA256';
    }

    my $expected_sig = Digest::SHA::hmac_sha256($payload, $self->secret);
    if ($sig ne $expected_sig) {
        ouch '500', 'Bad Signed JSON signature!';
    }
    return $data;
}

sub request_access_token {
    my ($self, $code) = @_;
    my $token = Facebook::Graph::AccessToken->new(
        code            => $code,
        postback        => $self->postback,
        secret          => $self->secret,
        app_id          => $self->app_id,
    )->request;
    $self->access_token($token->token);
    return $token;
}

sub request_extended_access_token {
    my ($self, $access_token) = @_;

	die "request_extended_access_token requires an access_token" unless $access_token or $self->has_access_token;
	$access_token = $access_token ? $access_token : $self->access_token;

    my $token = Facebook::Graph::AccessToken->new(
        access_token    => $access_token,
        postback        => $self->postback,
        secret          => $self->secret,
        app_id          => $self->app_id,
    )->request;
    $self->access_token($token->token);
    return $token;
}

sub convert_sessions {
    my ($self, $sessions) = @_;
    return Facebook::Graph::Session->new(
        secret          => $self->secret,
        app_id          => $self->app_id,
        sessions        => $sessions,
        )
        ->request
        ->as_hashref;
}

sub authorize {
    my ($self) = @_;
    return Facebook::Graph::Authorize->new(
        app_id          => $self->app_id,
        postback        => $self->postback,
    );
}

sub fetch {
    my ($self, $object_name, %params) = @_;
    return $self->query->find($object_name, %params)->request->as_hashref;
}

sub request {
    my ($self, $uri) = @_;
    return Facebook::Graph::Request->new->get($uri);
}

sub query {
    my ($self, %params) = @_;
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Query->new(%params);
}

sub batch_requests {
    my ($self, %params) = @_;
    $params{access_token} = $self->access_token;
    return Facebook::Graph::BatchRequests->new(%params);
}

sub picture {
    my ($self, $object_name, %params) = @_;
    $params{object_name} = $object_name;
    return Facebook::Graph::Picture->new( %params );
}

sub add_post {
    my ($self, $object_name, %params) = @_;
    if ($object_name) {
        $params{object_name} = $object_name;
    }
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Post->new( %params );
}


sub add_page_feed {
	my ($self, %params) = @_;
	if ($self->has_access_token) {
		$params{access_token} = $self->access_token;
	}
	if ($self->has_secret) {
		$params{secret} = $self->secret;
	}
	return Facebook::Graph::Page::Feed->new( %params );
};


sub add_photo {
    my ($self, $object_name, %params) = @_;
    if ($object_name) {
        $params{object_name} = $object_name;
    }
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Photo->new( %params );
}

sub add_checkin {
    my ($self, $object_name, %params) = @_;
    if ($object_name) {
        $params{object_name} = $object_name;
    }
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Checkin->new( %params );
}

sub add_comment {
    my ($self, $object_name, %params) = @_;
    $params{object_name} = $object_name;
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Comment->new( %params );
}

sub add_page_tab {
    my ($self, $object_name, $app_id, %params) = @_;

	die "page_id and app_id are required" unless $object_name and $app_id;

    $params{object_name} = $object_name;

    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }

    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }

	$params{app_id} = $app_id;

    return Facebook::Graph::Publish::PageTab->new( %params );
}



sub rsvp_maybe {
    my ($self, $object_name, %params) = @_;
    $params{object_name} = $object_name;
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::RSVPMaybe->new( %params );
}

sub rsvp_attending {
    my ($self, $object_name, %params) = @_;
    $params{object_name} = $object_name;
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::RSVPAttending->new( %params );
}

sub rsvp_declined {
    my ($self, $object_name, %params) = @_;
    $params{object_name} = $object_name;
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::RSVPDeclined->new( %params );
}


1;

=head1 NAME

Facebook::Graph - A fast and easy way to integrate your apps with Facebook.

=head1 NOTICE OF DEPRECATION

Facebook::Graph brought the world of Facebook to Perl, but as Facebook is massively changing their APIs it is impossible to keep up with a heavy weight module like Facebook::Graph. Instead, we recommend switching to the lighter weight L<Facebook::OpenGraph> module. We won't be removing Facebook::Graph from CPAN, but we won't be adding new features to keep up with all of Facebook's constant changes either.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;
 $fb->access_token($token);
 my $sarah_bownds = $fb->fetch('767598108');
 my $perl_page = $fb->fetch('16665510298');

Or better yet:

 my $sarah_bownds = $fb->query
    ->find('767598108')
    ->include_metadata
    ->select_fields(qw( id name picture ))
    ->request
    ->as_hashref;

 my $sarahs_picture_uri = $fb->picture('sarahbownds')->get_large->uri_as_string;

You can also do asynchronous calls like this:

 my $sarah = $fb->query->find('767598108'); 		# making request in background here
 # ... do stuff here ...
 my $hashref = $sarah->as_hashref;			# handling the response here


Or fetching a response from a URI you already have:

 my $hashref = $fb->request('https://graph.facebook.com/16665510298')->as_hashref;


=head2 Building A Privileged App

 my $fb = Facebook::Graph->new(
    app_id          => $facebook_application_id,
    secret          => $facebook_application_secret,
    postback        => 'https://www.yourapplication.com/facebook/oauth/postback',
 );

Get the user to authorize your app (only needed if you want to fetch non-public information or publish stuff):

 my $uri = $fb
    ->authorize
    ->extend_permissions(qw(offline_access publish_stream))
    ->uri_as_string;

 # redirect the user's browser to $uri

Handle the Facebook authorization code postback:

 my $q = Plack::Request->new($env);
 $fb->request_access_token($q->query_param('code'));

 #now retrieve extended access token
 $fb->request_extended_access_token; #extended access token now in $fb->access_token

Or if you already had the access token:

 $fb->access_token($token);
 $fb->request_extended_access_token;

Or simply:

 $fb->request_extended_access_token($token);

Get some info:

 my $user = $fb->fetch('me');
 my $friends = $fb->fetch('me/friends');
 my $perl_page = $fb->fetch('16665510298');

Use a different version of the API:

 my $user = $fb->fetch('me', api_version => 'v2.5');

=head1 DESCRIPTION

This is a Perl interface to the Facebook Graph API L<http://developers.facebook.com/docs/api>. With this module you can currently query public Facebook data, query privileged Facebook data, and build a privileged Facebook application. See the TODO for all that this module cannot yet do.

For example code, see L<Facebook::Graph::Cookbook>.

B<WARNING:> The work on this module has only just begun because the Graph API itself isn't very new, and I'm only working on it as I have some tuits. Therefore things are potentially subject to change drastically with each release.


=head1 METHODS

=head2 new ( [ params ] )

The constructor.

=head3 params

A hash of base parameters, just so you don't have to pass them around. If you only want to do public queries then these params are not needed.

=over

=item access_token

An access token string used to make Facebook requests as a privileged user. Required if you want to make privileged queries or perform privileged actions on Facebook objects.

=item app_id

The application id that you get from Facebook after registering (L<http://developers.facebook.com/setup/>) your application on their site. Required if you'll be calling the C<request_access_token>, C<convert_sessions>, or C<authorize> methods.

=item secret

The application secret that you get from Facebook after registering your application. Required if you'll be calling the C<request_access_token> or C<convert_sessions> methods.

=item postback

The URI that Facebook should post your authorization code back to. Required if you'll be calling the C<request_access_token> or C<authorize> methods.

B<NOTE:> It must be a sub URI of the URI that you put in the Application Settings > Connect > Connect URL field of your application's profile on Facebook.

=back


=head2 authorize ( )

Creates a L<Facebook::Graph::Authorize> object, which can be used to get permissions from a user for your application.


=head2 request_access_token ( code )

Creates a L<Facebook::Graph::AccessToken> object and fetches an access token from Facebook, which will allow everything you do with Facebook::Graph to work within user privileges rather than through the public interface. Returns a L<Facebook::Graph::AccessToken::Response> object, and also sets the C<access_token> property in the Facebook::Graph object.

=head2 request_extended_access_token ( access_token )

Note: access_token is optional. Creates a L<Facebook::Graph::AccessToken> object and fetches an (https://developers.facebook.com/docs/facebook-login/access-tokens/#extending) extended access token from Facebook.
This method accepts an optional access token. If you have called C<request_access_token> already on the Facebook::Graph object and C<access_token> is set, then you do not have to pass
in an access token. However, if you have an access token stored from a previous object, you will need to pass it in.

=head3 code

An authorization code string that you should have gotten by going through the C<authorize> process.


=head2 query ( )

Creates a L<Facebook::Graph::Query> object, which can be used to fetch and search data from Facebook.

=head2 batch_requests ( uri )

Creates a L<Facebook::Graph::BatchRequests> object, which can be used to send multiple requests in a single HTTP request.

=head2 request ( uri )

Fetch a Facebook::Graph URI you already have.

=head3 uri

The URI to fetch. For example: https://graph.facebook.com/amazon

=head2 fetch ( id )

Returns a hash reference of an object from facebook. A quick way to grab an object from Facebook. These two statements are identical:

 my $sarah = $fb->fetch('767598108');

 my $sarah = $fb->query->find('767598108')->request->as_hashref;

=head3 id

An object id like C<16665510298> for the Perl page.

=head2 picture ( id )

Returns a L<Facebook::Graph::Picture> object, which can be used to generate the URLs of the pictures of any object on Facebook.

=head3 id

An object id like C<16665510298> for the Perl page.



=head2 add_post ( [ id ] )

Creates a L<Facebook::Graph::Publish::Post> object, which can be used to publish data to a user's feed/wall.

=head2 add_page_feed ( )

Creates a L<Facebook::Graph::Page::Feed> object, which can be used to add a post to a Facebook page.

=head2 add_photo ( [ id ] )

Creates a L<Facebook::Graph::Publish::Photo> object, which can be used to publish a photo to a user's feed/wall.

=head3 id

Optionally provide an object id to place it on. Requires that you have administrative access to that page/object.


=head2 add_checkin ( [ id ] )

Creates a L<Facebook::Graph::Publish::Checkin> object, which can be used to publish a checkin to a location.

=head3 id

Optionally provide an user id to check in. Requires that you have administrative access to that user.


=head2 add_comment ( id )

Creates a L<Facebook::Graph::Publish::Comment> object that you can use to comment on a note.

=head3 id

The id of the post you want to comment on.


=head2 add_page_tab ( page_id, app_id )

Creates a L<Facebook::Graph::Publish::PageTab> object, which can be used to publish an app as a page tab.

=head3 id

Optionally provide an object id to place it on. Requires that you have administrative access to that page/object.



=head2 rsvp_maybe ( id )

RSVP as 'maybe' to an event.

=head3 id

The id of an event.

=head2 rsvp_attending ( id )

RSVP as 'attending' to an event.

=head3 id

The id of an event.

=head2 rsvp_declined ( id )

RSVP as 'declined' to an event.

=head3 id

The id of an event.



=head2 convert_sessions ( sessions )

A utility method to convert old sessions into access tokens that can be used with the Graph API. Returns an array reference of hash references of access tokens.

 [
   {
     "access_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
     "expires": 1271649600,
   },
   ...
 ]

See also L<Facebook::Graph::Session>.

=head3 sessions

An array reference of session ids from the old Facebook API.


=head2 parse_signed_request ( $signed_request )

Allows the decoding of signed requests for canvas applications to ensure data passed back from Facebook isn't tampered with. You can read more about this at L<http://developers.facebook.com/docs/authentication/canvas>.

=head3 $signed_request

A signature string passed from Facebook. To capture a signed request your app must be displayed within the Facebook canvas page and then you must pull the query parameter called C<signed_request> from the query string.

B<NOTE:> To get this passed to your app you must enable it in your migration settings for your app (L<http://www.facebook.com/developers/>).

=head1 EXCEPTIONS

This module throws exceptions when it encounters a problem. It uses L<Ouch> to throw the exception, and the Exception typically takes 3 parts: code, message, and a data portion that is the URI that was originally requested. For example:

 eval { $fb->call_some_method };
 if (kiss 500) {
   say "error: ". $@->message;
   say "uri: ".$@->data;
 }
 else {
   throw $@; # rethrow the error
 }

=head1 CAVEATS

The Facebook Graph API is a constantly moving target. As such some stuff that used to work, may stop working. Keep up to date with their changes here: L<https://developers.facebook.com/docs/apps/upgrading>

If you were using any version of Facebook::Graph before 1.1000, then you may be used to doing things like creating events through this API, or using a person's username instead of their ID, or making queries without an access token. You can't do any of those things anymore, because as of the Facebook Graph v2.0 API, none of them is supported any longer.


=head1 PREREQS

L<Moo>
L<JSON>
L<LWP::UserAgent>
L<LWP::Protocol::https>
L<URI>
L<DateTime>
L<DateTime::Format::Strptime>
L<MIME::Base64::URLSafe>
L<Ouch>

=head2 Optional

L<Digest::SHA> is used for signed requests. If you don't plan on using the signed request feature, then you do not need to install Digest::SHA.

=head1 SUPPORT

=over

=item Repository

L<http://github.com/rizen/Facebook-Graph>

=item Bug Reports

L<http://github.com/rizen/Facebook-Graph/issues>

=back


=head1 SEE ALSO

I highly recommend L<Facebook::OpenGraph>. I may even switch to it myself soon.


=head1 AUTHOR

JT Smith <jt_at_plainblack_dot_com>

=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2017 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


