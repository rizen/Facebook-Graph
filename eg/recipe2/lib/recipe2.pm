package recipe2;
use Dancer ':syntax';

our $VERSION = '0.1';

use Facebook::Graph;
use XML::FeedPP;
use Data::ICal;
use DateTime::Format::ICal;
use LWP::UserAgent;

before sub {
    if (request->path_info !~ m{^/facebook}) {
        if (session->{access_token} eq '') {
            request->path_info('/facebook/login')
        }
    }
};

get '/facebook/login' => sub {
    my $fb = Facebook::Graph->new( config->{facebook} );
    redirect $fb
        ->authorize
        ->extend_permissions( qw(email offline_access publish_stream create_event rsvp_event) )
        ->uri_as_string;
};

get '/facebook/postback/' => sub {
    my $params = request->params;
    my $fb = Facebook::Graph->new( config->{facebook} );
    $fb->request_access_token($params->{code});
    session access_token => $fb->access_token;
    redirect '/';
};

get '/' => sub {
    my $fb = Facebook::Graph->new( config->{facebook} );
    $fb->access_token(session->{access_token});
    my $response = $fb->query->find('me')->request;
    my $user = $response->as_hashref;
    template 'home.tt', { name => $user->{name}, response => $response->as_string }
};

get '/friends' => sub {
    my $fb = Facebook::Graph->new( config->{facebook} );
    $fb->access_token(session->{access_token});
    my $response = $fb->query->find('me/friends')->request;
    template 'friends.tt', { friends => $response->as_hashref->{data}, response => $response->as_string }
};

get '/rss-importer' => sub {
    template 'rss-importer.tt';
};


true;
