use Test::More tests => 5;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

my $sarah = $fb->query->find('sarahbownds');

is $sarah->object_name, 'sarahbownds', 'get the proper object name';
is $sarah->api_version, 'v2.8', 'get an api version';
is $sarah->generate_versioned_path('sarahbownds'), 'v2.8/sarahbownds', 'create a versioned api path';

