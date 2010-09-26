use Test::More tests => 6;
use lib '../lib';

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

die "You need to set an environment variable for FB_ACCESS_TOKEN to test this" unless $ENV{FB_ACCESS_TOKEN};

$fb->access_token($ENV{FB_ACCESS_TOKEN});

my $response = $fb->add_post
  ->set_message('Testing')
  ->publish;
my $out = $response->as_hashref;
ok(ref $out eq 'HASH', 'got a hash back on simple post') or debug($response->as_json);
ok(exists $out->{id}, 'we got back an id on simple post');


$response = $fb->add_post
    ->set_message('TESTING: I like Perl.')
    ->set_picture_uri('http://www.perl.org/i/camel_head.png')
    ->set_link_uri('http://www.perl.org/')
    ->set_link_name('Perl.org')
    ->set_link_caption('Perl is a programming language.')
    ->set_link_description('A link to the Perl web site.')
    ->publish;
ok(ref $out eq 'HASH', 'got a hash back on complex post') or debug($response->as_json);
ok(exists $out->{id}, 'we got back an id on complex post');


