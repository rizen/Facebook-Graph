requires 'perl', '5.012001';
requires 'JSON', '2.16';
requires 'Ouch', '0.0400';
requires 'LWP::Protocol::https', '6.06';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
