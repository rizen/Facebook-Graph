use Test::More;
use strict;
use lib '../lib';

die "You need to set an environment variable for FB_APP_ID && FB_SECRET to test this" unless $ENV{FB_APP_ID} && $ENV{FB_SECRET};

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new(
    secret      => $ENV{FB_SECRET},
    app_id      => $ENV{FB_APP_ID},
    postback    => 'https://www.facebook.com/connect/login_success.html',   # this is used for desktop apps, so we're cheating a bit for this test
    );
isa_ok($fb, 'Facebook::Graph');

my $uri = $fb->authorize->extend_permissions(qw(offline_access read_stream publish_stream))->uri_as_string;

print "Point your browser here: $uri

After authenticating paste the response URL here:

";

my $return_url = <>;

note $return_url;

$return_url =~ m{\s*code=([\w\.\-\/\_]+)\s*};
my $code = $1;

note "CODE: $code";

$fb->request_access_token($code);

note "ACCESS TOKEN: ". $fb->access_token;

ok $fb->access_token, 'got an access token';

my $sarah = $fb->fetch('sarahbownds');
ok(exists $sarah->{updated_time}, 'able to make a request using the new token');


done_testing();
