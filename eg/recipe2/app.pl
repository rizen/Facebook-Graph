use Dancer;
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

post '/rss-importer' => sub {
    my $fb = Facebook::Graph->new( config->{facebook} );
    $fb->access_token(session->{access_token});
    my $feed = XML::FeedPP->new(request->params->{rss_uri});
    foreach my $item ($feed->get_item) {
        $fb->add_post
            ->set_message('Created by RSS Feed Importer')
            ->set_link_uri($item->link)
            ->set_link_name($item->title)
            ->set_link_description($item->description)
            ->publish;
    }
    template 'rss-importer-post.tt';
};

get '/ical-importer' => sub {
    template 'ical-importer.tt';
};

post '/ical-importer' => sub {
    my $fb = Facebook::Graph->new( config->{facebook} );
    $fb->access_token(session->{access_token});

    # download ical feed
    my $ical = LWP::UserAgent->new
	->get(request->params->{ical_uri})
	->content;

    # process ical into calendar
    my $calendar = Data::ICal->new( data => $ical );

    # post events
    foreach my $entry (@{$calendar->entries}) {
       $fb->add_event
           ->set_name($entry->properties->{summary}[0]->value)
           ->set_location($entry->properties->{location}[0]->value)
           ->set_description($entry->properties->{description}[0]->value)
           ->set_start_time(DateTime::Format::ICal->parse_datetime($entry->properties->{dtstart}[0]->value))
           ->set_end_time(DateTime::Format::ICal->parse_datetime($entry->properties->{dtend}[0]->value))
           ->publish;
    }

    template 'ical-importer-post.tt';
};

dance;

