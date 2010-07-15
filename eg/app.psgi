use strict;
use Plack::App::URLMap;
use Plack::Request;
use Facebook::Graph;
use URI;

my $urlmap = Plack::App::URLMap->new;
 
my $fb = Facebook::Graph->new(
    postback    => 'https://www.yourapplication.com/facebook/postback',
    app_id      => 'Put Your Application ID Here',
    secret      => 'Put Your Application Secret Here',
);



my $connect = sub {
    my $env = shift;
    my $request = Plack::Request->new( $env );
    my $response = $request->new_response;
    $response->redirect(
        $fb
        ->authorize
        ->extend_permissions( qw(email offline_access) )
        ->uri_as_string
    );
    return $response->finalize;
};

$urlmap->map("/facebook" => $connect);



my $postback = sub {
    my $env = shift;
    my $request = Plack::Request->new( $env );

    # turn our authorization code into an access token
    $fb->request_access_token($request->param('code'));

    # store our access token to a database, a cookie, or pass it throuh the URL
    my $uri = URI->new('https://www.yourapplication.com/search');
    $uri->query_form( access_token => $fb->access_token );

    my $response = $request->new_response;
    $response->redirect( $uri->as_string );
    return $response->finalize;
};

$urlmap->map("/facebook/postback" => $postback);



my $search = sub {
    my $env = shift;
    my $request = Plack::Request->new( $env );

    # display a search
    my $out = '<html>
    <body>
    <form>
    <input type="hidden" name="access_token" value="'. $request->param('access_token') .'
    <input type="text" name="q" value="'. $request->param('q') .'">
    <input type="submit" value="Search">
    </form>
    <pre>
    ';

    # display the results if a search is made
    if ($request->param('q')) {
        my $response = $fb->query
            ->search($request->param('q'), 'user')
            ->limit_results(10)
            ->request;
        $out .= $response->as_json;
    }

    # close everything up
    $out .= '
    </pre>
    </body>
    </html>
    ';

    my $response = $request->new_response;
    $response->status(200);
    $response->content_type('text/html');
    $response->body($out);
    return $response->finalize;
};

$urlmap->map("/search" => $search);



$urlmap->to_app;

