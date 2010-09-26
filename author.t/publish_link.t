use Test::More tests => 4;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

die "You need to set an environment variable for FB_ACCESS_TOKEN to test this" unless $ENV{FB_ACCESS_TOKEN};

$fb->access_token($ENV{FB_ACCESS_TOKEN});

my $response = $fb->add_link
  ->set_message('The Game Crafter')
  ->set_link_uri('http://www.thegamecrafter.com/')
  ->publish;
my $out = eval{$response->as_hashref};
use Data::Dumper;
die Dumper($@) if $@;
ok(ref $out eq 'HASH', 'got a hash back') or debug($response->as_json);
ok(exists $out->{id}, 'we got back an id');

