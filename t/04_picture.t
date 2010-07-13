use Test::More tests => 7;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

my $sarah_pic = $fb->picture('sarahbownds');
isa_ok($sarah_pic, 'Facebook::Graph::Picture');

is($sarah_pic->uri_as_string, 'https://graph.facebook.com/sarahbownds/picture', 'default pic');
is($sarah_pic->get_small->uri_as_string, 'https://graph.facebook.com/sarahbownds/picture?type=small', 'small pic');
is($sarah_pic->get_large->uri_as_string, 'https://graph.facebook.com/sarahbownds/picture?type=large', 'large pic');
is($sarah_pic->get_square->uri_as_string, 'https://graph.facebook.com/sarahbownds/picture?type=square', 'square pic');
