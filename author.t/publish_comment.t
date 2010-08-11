use Test::More tests => 4;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

die "You need to set an environment variable for FB_ACCESS_TOKEN to test this" unless $ENV{FB_ACCESS_TOKEN};

$fb->access_token($ENV{FB_ACCESS_TOKEN});

my $response = $fb->add_comment('1647395831_1452098916277')
  ->set_message('This is a test comment.')
  ->publish;
my $out = $response->as_hashref;
ok(ref $out eq 'HASH', 'got a hash back') or debug($response->as_json);
ok(exists $out->{id}, 'we got back an id');

