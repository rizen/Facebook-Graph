use Test::More tests => 12;
use lib '../lib';
use Ouch;

use_ok('Facebook::Graph');
my $fb = Facebook::Graph->new;
isa_ok($fb, 'Facebook::Graph');

my $sarah_query = $fb->query
    ->find('sarahbownds')
    ->select_fields(qw(name id))
    ->include_metadata;
isa_ok($sarah_query, 'Facebook::Graph::Query');
is($sarah_query->uri_as_string, 'https://graph.facebook.com/sarahbownds?fields=name%2Cid&metadata=1', 'seems to generate uris correctly');

my $sarah_response = $sarah_query->request;
isa_ok($sarah_response, 'Facebook::Graph::Response');
my $sarah = eval{$sarah_response->as_hashref};

die $@->[1] if $@;

ok(ref $sarah eq 'HASH', 'got a hash ref back');
is($sarah->{id}, '767598108', 'got sarah');
is($sarah->{name}, 'Sarah Bownds', 'know her name');
is(scalar(keys %{$sarah}), 3, 'only fetched the things i asked for');
is($sarah->{metadata}{type}, 'user', 'she is a user');

eval { $fb->query->select_fields('')->request->as_json };
is($@->code, 400, 'exception inherits http status code');
is($@->message, 'Could not execute request (https://graph.facebook.com?fields=): GraphMethodException - Unsupported get request.', 'exception gives good detail');

