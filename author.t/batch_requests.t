use Test::More tests => 3;
use lib '../lib';
use Ouch;
use Facebook::Graph;

my $fb = Facebook::Graph->new(access_token => $ENV{FB_ACCESS_TOKEN});

my @batches = $fb->batch_requests
    ->add_request({"method" => "GET", "relative_url" => '767598108'})
    ->add_request({"method" => "GET", "relative_url" => '16665510298'})
    ->request;

is($batches[0]->{data}->{id}, '767598108', 'got sarah');
is($batches[0]->{data}->{name}, 'Sarah Bownds', 'know her name');

is($batches[1]->{data}->{id}, '16665510298', 'know perl page');
