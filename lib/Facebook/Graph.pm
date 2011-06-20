package Facebook::Graph;

use Any::Moose;
use MIME::Base64::URLSafe;
use JSON;
use Facebook::Graph::AccessToken;
use Facebook::Graph::Authorize;
use Facebook::Graph::Query;
use Facebook::Graph::Picture;
use Facebook::Graph::Publish::Post;
use Facebook::Graph::Publish::Checkin;
use Facebook::Graph::Publish::Like;
use Facebook::Graph::Publish::Comment;
use Facebook::Graph::Publish::Note;
use Facebook::Graph::Publish::Link;
use Facebook::Graph::Publish::Event;
use Facebook::Graph::Publish::RSVPMaybe;
use Facebook::Graph::Publish::RSVPAttending;
use Facebook::Graph::Publish::RSVPDeclined;
use Ouch;
use LWP::UserAgent;

has app_id => (
    is      => 'ro',
);

has secret => (
    is          => 'ro',
    predicate   => 'has_secret',
);

has postback => (
    is      => 'ro',
);

has access_token => (
    is          => 'rw',
    predicate   => 'has_access_token',
);

has ua => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        LWP::UserAgent->new;
    },
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
        ua              => $self->ua,
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
        ua              => $self->ua,
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
    my ($self, $object_name) = @_;
    return $self->query->find($object_name)->request->as_hashref;
}

sub query {
    my ($self) = @_;
    my %params = ( ua => $self->ua );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Query->new(%params);
}

sub picture {
    my ($self, $object_name) = @_;
    return Facebook::Graph::Picture->new( object_name => $object_name );
}

sub add_post {
    my ($self, $object_name) = @_;
    my %params = ( ua => $self->ua );
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

sub add_checkin {
    my ($self, $object_name) = @_;
    my %params = ( ua => $self->ua );
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

sub add_like {
    my ($self, $object_name) = @_;
    my %params = (
        object_name => $object_name,
        ua          => $self->ua,
    );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Like->new( %params );
}

sub add_comment {
    my ($self, $object_name) = @_;
    my %params = (
        object_name => $object_name,
    );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Comment->new( %params );
}

sub add_note {
    my ($self) = @_;
    my %params = ( ua => $self->ua );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Note->new( %params );
}

sub add_link {
    my ($self) = @_;
    my %params = ( ua => $self->ua );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Link->new( %params );
}

sub add_event {
    my ($self, $object_name) = @_;
    my %params = ( ua => $self->ua );
    if ($object_name) {
        $params{object_name} = $object_name;
    }
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::Event->new( %params );
}

sub rsvp_maybe {
    my ($self, $object_name) = @_;
    my %params = (
        object_name => $object_name,
        ua          => $self->ua,
    );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::RSVPMaybe->new( %params );
}

sub rsvp_attending {
    my ($self, $object_name) = @_;
    my %params = (
        object_name => $object_name,
        ua          => $self->ua,
    );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::RSVPAttending->new( %params );
}

sub rsvp_declined {
    my ($self, $object_name) = @_;
    my %params = (
        object_name => $object_name,
        ua          => $self->ua,
    );
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Publish::RSVPDeclined->new( %params );
}



no Any::Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph - A fast and easy way to integrate your apps with Facebook.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;
 my $sarah_bownds = $fb->fetch('sarahbownds');
 my $perl_page = $fb->fetch('16665510298');
 
Or better yet:

 my $sarah_bownds = $fb->query
    ->find('sarahbownds')
    ->include_metadata
    ->select_fields(qw( id name picture ))
    ->request
    ->as_hashref;
    
 my $sarahs_picture_uri = $fb->picture('sarahbownds')->get_large->uri_as_string;

Or fetching a response from a URI you already have:

 my $response = $fb->query
    ->request('https://graph.facebook.com/btaylor')
    ->as_hashref;
 
 
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
 
Or if you already had the access token:

 $fb->access_token($token);
 
Get some info:

 my $user = $fb->fetch('me');
 my $friends = $fb->fetch('me/friends');
 my $sarah_bownds = $fb->fetch('sarahbownds');

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

=head3 code

An authorization code string that you should have gotten by going through the C<authorize> process.


=head2 query ( )

Creates a L<Facebook::Graph::Query> object, which can be used to fetch and search data from Facebook.


=head2 fetch ( id )

Returns a hash reference of an object from facebook. A quick way to grab an object from Facebook. These two statements are identical:

 my $sarah = $fb->fetch('sarahbownds');
 
 my $sarah = $fb->query->find('sarahbownds')->request->as_hashref;

=head3 id

An profile id like C<sarahbownds> or an object id like C<16665510298> for the Perl page.


=head2 picture ( id )

Returns a L<Facebook::Graph::Picture> object, which can be used to generate the URLs of the pictures of any object on Facebook.

=head3 id

An profile id like C<sarahbownds> or an object id like C<16665510298> for the Perl page.



=head2 add_post ( [ id ] )

Creates a L<Facebook::Graph::Publish::Post> object, which can be used to publish data to a user's feed/wall.

=head3 id

Optionally provide an object id to place it on. Requires that you have administrative access to that page/object.


=head2 add_checkin ( [ id ] )

Creates a L<Facebook::Graph::Publish::Checkin> object, which can be used to publish a checkin to a location.

=head3 id

Optionally provide an user id to check in. Requires that you have administrative access to that user.


=head2 add_like ( id )

Creates a L<Facebook::Graph::Publish::Like> object to tell everyone about a post you like.

=head3 id

The id of a post you like.


=head2 add_comment ( id )

Creates a L<Facebook::Graph::Publish::Comment> object that you can use to comment on a note.

=head3 id

The id of the post you want to comment on.


=head2 add_note ( )

Creates a L<Facebook::Graph::Publish::Note> object, which can be used to publish notes.


=head2 add_link ( )

Creates a L<Facebook::Graph::Publish::Link> object, which can be used to publish links.


=head2 add_event ( [id] )

Creates a L<Facebook::Graph::Publish::Event> object, which can be used to publish events.

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


=head2 parse_signed_request ( signed_request )

Allows the decoding of signed requests for canvas applications to ensure data passed back from Facebook isn't tampered with. You can read more about this at L<http://developers.facebook.com/docs/authentication/canvas>.

=head3 signed_request

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


=head1 TODO

I still need to add publishing albums/photos, deleting of content, impersonation, and analytics to have a feature complete API. In addition, the module could use a lot more tests.


=head1 PREREQS

L<Any::Moose>
L<JSON>
L<LWP>
L<LWP::Protocol::https>
L<Mozilla::CA>
L<URI>
L<DateTime>
L<DateTime::Format::Strptime>
L<MIME::Base64::URLSafe>
L<URI::Encode>
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

If you're looking for a fully featured Facebook client in Perl I highly recommend L<WWW::Facebook::API>. It does just about everything, it just uses the old Facebook API.

=head1 AUTHOR

JT Smith <jt_at_plainblack_dot_com>

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


