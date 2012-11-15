use Test::More tests => 4;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

my $sarah = $fb->fetch('sarahbownds');
ok(ref $sarah eq 'HASH', 'got a hash ref back');
is($sarah->{id}, '767598108', 'got sarah');

use Data::Dumper;
note Dumper $sarah;
