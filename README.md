# NAME

Facebook::Graph - A fast and easy way to integrate your apps with Facebook.

# NOTICE OF DEPRECATION

Facebook::Graph brought the world of Facebook to Perl, but as Facebook is massively changing their APIs it is impossible to keep up with a heavy weight module like Facebook::Graph. Instead, we recommend switching to the lighter weight [Facebook::OpenGraph](https://metacpan.org/pod/Facebook::OpenGraph) module. We won't be removing Facebook::Graph from CPAN, but we won't be adding new features to keep up with all of Facebook's constant changes either.

# SYNOPSIS

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

    my $sarah = $fb->query->find('767598108');             # making request in background here
    # ... do stuff here ...
    my $hashref = $sarah->as_hashref;                      # handling the response here

Or fetching a response from a URI you already have:

    my $hashref = $fb->request('https://graph.facebook.com/16665510298')->as_hashref;

## Building A Privileged App

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

# DESCRIPTION

This is a Perl interface to the Facebook Graph API [http://developers.facebook.com/docs/api](http://developers.facebook.com/docs/api). With this module you can currently query public Facebook data, query privileged Facebook data, and build a privileged Facebook application. See the TODO for all that this module cannot yet do.

For example code, see [Facebook::Graph::Cookbook](https://metacpan.org/pod/Facebook::Graph::Cookbook).

**WARNING:** The work on this module has only just begun because the Graph API itself isn't very new, and I'm only working on it as I have some tuits. Therefore things are potentially subject to change drastically with each release.

# METHODS

## new ( \[ params \] )

The constructor.

### params

A hash of base parameters, just so you don't have to pass them around. If you only want to do public queries then these params are not needed.

- access\_token

    An access token string used to make Facebook requests as a privileged user. Required if you want to make privileged queries or perform privileged actions on Facebook objects.

- app\_id

    The application id that you get from Facebook after registering ([http://developers.facebook.com/setup/](http://developers.facebook.com/setup/)) your application on their site. Required if you'll be calling the `request_access_token`, `convert_sessions`, or `authorize` methods.

- secret

    The application secret that you get from Facebook after registering your application. Required if you'll be calling the `request_access_token` or `convert_sessions` methods.

- postback

    The URI that Facebook should post your authorization code back to. Required if you'll be calling the `request_access_token` or `authorize` methods.

    **NOTE:** It must be a sub URI of the URI that you put in the Application Settings > Connect > Connect URL field of your application's profile on Facebook.

## authorize ( )

Creates a [Facebook::Graph::Authorize](https://metacpan.org/pod/Facebook::Graph::Authorize) object, which can be used to get permissions from a user for your application.

## request\_access\_token ( code )

Creates a [Facebook::Graph::AccessToken](https://metacpan.org/pod/Facebook::Graph::AccessToken) object and fetches an access token from Facebook, which will allow everything you do with Facebook::Graph to work within user privileges rather than through the public interface. Returns a [Facebook::Graph::AccessToken::Response](https://metacpan.org/pod/Facebook::Graph::AccessToken::Response) object, and also sets the `access_token` property in the Facebook::Graph object.

## request\_extended\_access\_token ( access\_token )

Note: access\_token is optional. Creates a [Facebook::Graph::AccessToken](https://metacpan.org/pod/Facebook::Graph::AccessToken) object and fetches an (https://developers.facebook.com/docs/facebook-login/access-tokens/#extending) extended access token from Facebook.
This method accepts an optional access token. If you have called `request_access_token` already on the Facebook::Graph object and `access_token` is set, then you do not have to pass
in an access token. However, if you have an access token stored from a previous object, you will need to pass it in.

### code

An authorization code string that you should have gotten by going through the `authorize` process.

## query ( )

Creates a [Facebook::Graph::Query](https://metacpan.org/pod/Facebook::Graph::Query) object, which can be used to fetch and search data from Facebook.

## batch\_requests ( uri )

Creates a [Facebook::Graph::BatchRequests](https://metacpan.org/pod/Facebook::Graph::BatchRequests) object, which can be used to send multiple requests in a single HTTP request.

## request ( uri )

Fetch a Facebook::Graph URI you already have.

### uri

The URI to fetch. For example: https://graph.facebook.com/amazon

## fetch ( id )

Returns a hash reference of an object from facebook. A quick way to grab an object from Facebook. These two statements are identical:

    my $sarah = $fb->fetch('767598108');

    my $sarah = $fb->query->find('767598108')->request->as_hashref;

### id

An object id like `16665510298` for the Perl page.

## picture ( id )

Returns a [Facebook::Graph::Picture](https://metacpan.org/pod/Facebook::Graph::Picture) object, which can be used to generate the URLs of the pictures of any object on Facebook.

### id

An object id like `16665510298` for the Perl page.

## add\_post ( \[ id \] )

Creates a [Facebook::Graph::Publish::Post](https://metacpan.org/pod/Facebook::Graph::Publish::Post) object, which can be used to publish data to a user's feed/wall.

## add\_page\_feed ( )

Creates a [Facebook::Graph::Page::Feed](https://metacpan.org/pod/Facebook::Graph::Page::Feed) object, which can be used to add a post to a Facebook page.

## add\_photo ( \[ id \] )

Creates a [Facebook::Graph::Publish::Photo](https://metacpan.org/pod/Facebook::Graph::Publish::Photo) object, which can be used to publish a photo to a user's feed/wall.

### id

Optionally provide an object id to place it on. Requires that you have administrative access to that page/object.

## add\_checkin ( \[ id \] )

Creates a [Facebook::Graph::Publish::Checkin](https://metacpan.org/pod/Facebook::Graph::Publish::Checkin) object, which can be used to publish a checkin to a location.

### id

Optionally provide an user id to check in. Requires that you have administrative access to that user.

## add\_comment ( id )

Creates a [Facebook::Graph::Publish::Comment](https://metacpan.org/pod/Facebook::Graph::Publish::Comment) object that you can use to comment on a note.

### id

The id of the post you want to comment on.

## add\_page\_tab ( page\_id, app\_id )

Creates a [Facebook::Graph::Publish::PageTab](https://metacpan.org/pod/Facebook::Graph::Publish::PageTab) object, which can be used to publish an app as a page tab.

### id

Optionally provide an object id to place it on. Requires that you have administrative access to that page/object.

## rsvp\_maybe ( id )

RSVP as 'maybe' to an event.

### id

The id of an event.

## rsvp\_attending ( id )

RSVP as 'attending' to an event.

### id

The id of an event.

## rsvp\_declined ( id )

RSVP as 'declined' to an event.

### id

The id of an event.

## convert\_sessions ( sessions )

A utility method to convert old sessions into access tokens that can be used with the Graph API. Returns an array reference of hash references of access tokens.

    [
      {
        "access_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "expires": 1271649600,
      },
      ...
    ]

See also [Facebook::Graph::Session](https://metacpan.org/pod/Facebook::Graph::Session).

### sessions

An array reference of session ids from the old Facebook API.

## parse\_signed\_request ( $signed\_request )

Allows the decoding of signed requests for canvas applications to ensure data passed back from Facebook isn't tampered with. You can read more about this at [http://developers.facebook.com/docs/authentication/canvas](http://developers.facebook.com/docs/authentication/canvas).

### $signed\_request

A signature string passed from Facebook. To capture a signed request your app must be displayed within the Facebook canvas page and then you must pull the query parameter called `signed_request` from the query string.

**NOTE:** To get this passed to your app you must enable it in your migration settings for your app ([http://www.facebook.com/developers/](http://www.facebook.com/developers/)).

# EXCEPTIONS

This module throws exceptions when it encounters a problem. It uses [Ouch](https://metacpan.org/pod/Ouch) to throw the exception, and the Exception typically takes 3 parts: code, message, and a data portion that is the URI that was originally requested. For example:

    eval { $fb->call_some_method };
    if (kiss 500) {
      say "error: ". $@->message;
      say "uri: ".$@->data;
    }
    else {
      throw $@; # rethrow the error
    }

# CAVEATS

The Facebook Graph API is a constantly moving target. As such some stuff that used to work, may stop working. Keep up to date with their changes here: [https://developers.facebook.com/docs/apps/upgrading](https://developers.facebook.com/docs/apps/upgrading)

If you were using any version of Facebook::Graph before 1.1000, then you may be used to doing things like creating events through this API, or using a person's username instead of their ID, or making queries without an access token. You can't do any of those things anymore, because as of the Facebook Graph v2.0 API, none of them is supported any longer.

# PREREQS

[Moo](https://metacpan.org/pod/Moo)
[JSON](https://metacpan.org/pod/JSON)
[LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)
[LWP::Protocol::https](https://metacpan.org/pod/LWP::Protocol::https)
[URI](https://metacpan.org/pod/URI)
[DateTime](https://metacpan.org/pod/DateTime)
[DateTime::Format::Strptime](https://metacpan.org/pod/DateTime::Format::Strptime)
[MIME::Base64](https://metacpan.org/pod/MIME::Base64)
[Ouch](https://metacpan.org/pod/Ouch)

## Optional

[Digest::SHA](https://metacpan.org/pod/Digest::SHA) is used for signed requests. If you don't plan on using the signed request feature, then you do not need to install Digest::SHA.

# SUPPORT

- Repository

    [http://github.com/rizen/Facebook-Graph](http://github.com/rizen/Facebook-Graph)

- Bug Reports

    [http://github.com/rizen/Facebook-Graph/issues](http://github.com/rizen/Facebook-Graph/issues)

# SEE ALSO

I highly recommend [Facebook::OpenGraph](https://metacpan.org/pod/Facebook::OpenGraph). I may even switch to it myself soon.

# AUTHOR

JT Smith &lt;jt\_at\_plainblack\_dot\_com>

# LEGAL

Facebook::Graph is Copyright 2010 - 2017 Plain Black Corporation ([http://www.plainblack.com](http://www.plainblack.com)) and is licensed under the same terms as Perl itself.
