use strict;
use warnings;

use Test::More tests => 4;
use lib '../lib';
use HTTP::Response;
use JSON;

use_ok('Facebook::Graph');
use_ok('Facebook::Graph::AccessToken');

my $fb = Facebook::Graph->new(
    app_id   => 12345,
    secret   => 'secret',
    postback => 'https://sample.com/callback'
);

my $expires = 5183814;
my $token   = '123456789XXXXXXXXXXX';

subtest 'v2.8 or older' => sub {
    no warnings 'redefine';
    local *Facebook::Graph::AccessToken::request = sub {
        return Facebook::Graph::AccessToken::Response->new(
            response => HTTP::Response->new(
                200,
                'OK',
                [
                    'Content-Type'         => 'text/plain; charset=UTF-8',
                    'facebook-api-version' => 'v2.8',
                ],
                sprintf('access_token=%s&expires=%d', $token, $expires),
            ),
        );
    };

    my $token_obj = $fb->request_access_token('dummy_code');
    is($token_obj->token, $token);
    is($token_obj->expires, $expires);
};

subtest 'v2.3 or later' => sub {
    no warnings 'redefine';
    local *Facebook::Graph::AccessToken::request = sub {
        return Facebook::Graph::AccessToken::Response->new(
            response => HTTP::Response->new(
                200,
                'OK',
                [
                    'Content-Type'         => 'text/plain; charset=UTF-8',
                    'facebook-api-version' => 'v2.3',
                ],
                JSON->new->encode(+{
                    access_token => $token,
                    expires_in   => $expires,
                    token_type   => 'bearer',
                }),
            ),
        );
    };

    my $token_obj = $fb->request_access_token('dummy_code');
    is($token_obj->token, $token);
    is($token_obj->expires, $expires);
};

__END__
