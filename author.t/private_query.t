use strict;
use warnings;

use Test::More;
use lib '../lib';
use Ouch;

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

die "You need to set an environment variable for FB_ACCESS_TOKEN to test this" unless $ENV{FB_ACCESS_TOKEN};
$fb->access_token($ENV{FB_ACCESS_TOKEN});

my $sarah_query = $fb->query(api_version => 'v2.7')
    ->find('767598108')
    ->select_fields(qw(name id))
    ->include_metadata;
isa_ok($sarah_query, 'Facebook::Graph::Query');
my $got = URI->new($sarah_query->uri_as_string);
is($got->scheme, 'https', 'scheme of generated uri');
is($got->host, 'graph.facebook.com', 'host of generated uri');
is($got->path, '/v2.7/767598108', 'path of generated uri');
my %query = $got->query_form;
is_deeply(\%query, {fields => 'name,id', metadata => '1', access_token => $ENV{FB_ACCESS_TOKEN}}, 'query of generated uri');

my $sarah_response = $sarah_query->request;
isa_ok($sarah_response, 'Facebook::Graph::Response');
my $sarah = eval{$sarah_response->as_hashref};

die $@ if $@;

ok(ref $sarah eq 'HASH', 'got a hash ref back');
is($sarah->{id}, '767598108', 'got sarah');
is($sarah->{name}, 'Sarah Bownds', 'know her name');
is(scalar(keys %{$sarah}), 3, 'only fetched the things i asked for');
is($sarah->{metadata}{type}, 'user', 'she is a user');

eval { $fb->query->select_fields('')->request->as_json };
is($@->code, 400, 'exception inherits http status code');
like($@->message, qr#\QUnsupported get request\E#, 'exception gives good detail');

done_testing();
