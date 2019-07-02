requires 'perl', '5.012001';
requires 'JSON', '2.16';
requires 'Ouch', '0.0400';
requires 'LWP::Protocol::https', '6.06';
requires 'Moo';
requires 'MIME::Base64', '3.15';
requires 'Digest::SHA', '6.02';


on 'test' => sub {
    requires 'Test::More', '0.98';
};
