use Test::More tests => 4;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

die "You need to set an environment variable for FB_ACCESS_TOKEN to test this" unless $ENV{FB_ACCESS_TOKEN};

$fb->access_token($ENV{FB_ACCESS_TOKEN});

my $response = $fb->add_event
  ->set_start_time(DateTime->new(year => 2012, month => 1, day => 1))
  ->set_end_time(DateTime->new(year => 2012, month => 1, day => 2))
  ->set_name('The Apocalypse')
  ->set_description('The date that idiots believe the end of the world is coming.')
  ->set_location('The Whole World!')
  ->publish;
my $out = $response->as_hashref;
ok(ref $out eq 'HASH', 'got a hash back') or debug($response->as_json);
ok(exists $out->{id}, 'we got back an id');

