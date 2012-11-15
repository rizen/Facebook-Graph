use Test::More tests => 3;
use lib '../lib';
use Ouch;
use Facebook::Graph;

my $fb = Facebook::Graph->new(access_token => $ENV{FB_ACCESS_TOKEN});

my @batches = $fb->batch_requests
    ->add_request({"method" => "GET", "relative_url" => 'sarahbownds'})
    ->add_request({"method" => "GET", "relative_url" => '113515098748988'})
    ->request;

is($batches[0]->{data}->{id}, '767598108', 'got sarah');
is($batches[0]->{data}->{name}, 'Sarah Bownds', 'know her name');

# 'location' => 'San Francisco Design Center',
is($batches[1]->{data}->{location}, 'San Francisco Design Center', 'know event location');
