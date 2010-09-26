use Test::More tests => 4;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

die "You need to set an environment variable for FB_ACCESS_TOKEN to test this" unless $ENV{FB_ACCESS_TOKEN};

$fb->access_token($ENV{FB_ACCESS_TOKEN});

my $sarah = eval{$fb->fetch('sarahbownds')};
use Data::Dumper;
die Dumper($@) if $@;
ok(ref $sarah eq 'HASH', 'got a hash ref back');
ok(exists $sarah->{about}, 'got sarah');

