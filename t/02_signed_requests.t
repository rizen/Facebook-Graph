use Test::More tests => 3;
use lib '../lib';
use JSON;

my $signed_request = "vlXgu64BQGFSQrY0ZcJBZASMvYvTHu9GQ0YM9rjPSso.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsIjAiOiJwYXlsb2FkIn0";
my $secret = "secret";

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new(secret => $secret);
isa_ok($fb, 'Facebook::Graph');

is( JSON->new->canonical(1)->encode($fb->parse_signed_request($signed_request)), '{"0":"payload","algorithm":"HMAC-SHA256"}', 'parse_signed_request');

