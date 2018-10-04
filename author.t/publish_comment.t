use strict;
use warnings;

use Test::More;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

die "You need to set an environment variable for FB_ACCESS_TOKEN to test this" unless $ENV{FB_ACCESS_TOKEN};

$fb->access_token($ENV{FB_ACCESS_TOKEN});

my $response = $fb->add_post('1647395831')
    ->set_message('This is a test post of the Facebook::Graph perl module with epoch: '.time())
    ->publish;
my $out = $response->as_hashref;
ok(ref $out eq 'HASH', 'got a hash back') or debug($response->as_json);
ok(exists $out->{id}, 'we got back an id');

$response = $fb->add_comment($out->{id})
  ->set_message('This is a test comment.')
  ->publish;
$out = $response->as_hashref;
ok(ref $out eq 'HASH', 'got a hash back') or debug($response->as_json);
ok(exists $out->{id}, 'we got back an id');

done_testing();
