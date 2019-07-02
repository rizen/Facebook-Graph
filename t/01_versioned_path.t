use strict;
use warnings;

use Test::More tests => 5;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

my $sarah = $fb->query->find('sarahbownds');

is $sarah->object_name, 'sarahbownds', 'get the proper object name';
is $sarah->api_version, 'v3.1', 'get an api version';
is $sarah->generate_versioned_path('sarahbownds'), 'v3.1/sarahbownds', 'create a versioned api path';

