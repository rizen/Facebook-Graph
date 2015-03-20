use Test::More tests => 8;
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
ok(ref $out eq 'HASH', 'got a hash back on simple post') or diag($response->as_json);
ok(exists $out->{id}, 'we got back an id on simple post');

$response = $fb->add_post
    ->set_message('TESTING: I like Perl.')
    ->set_picture_uri('http://st.pimg.net/perlweb/images/camel_head.v25e738a.png')
    ->set_link_uri('http://www.perl.org/')
    ->set_link_name('Perl.org')
    ->set_link_caption('Perl is a programming language.')
    ->set_link_description('A link to the Perl web site.')
    ->publish;
$out = $response->as_hashref;
ok(ref $out eq 'HASH', 'got a hash back on complex post') or diag($response->as_json);
ok(exists $out->{id}, 'we got back an id on complex post');


$response = $fb->add_post(176943642329328)
  ->set_message('This is me testing')
    ->set_link_uri('http://www.perl.org/')
  ->publish;
$out = $response->as_hashref;
ok(ref $out eq 'HASH', 'got a hash back on simple post to community page') or diag($response->as_json);
ok(exists $out->{id}, 'we got back an id on simple post to community page');


