package Facebook::Graph;

use Moose;
use Facebook::Graph::AccessToken;
use Facebook::Graph::Authorize;
use Facebook::Graph::Query;
with 'Facebook::Graph::Role::Uri';
use LWP::UserAgent;
use JSON;

has app_id => (
    is      => 'ro',
);

has secret => (
    is      => 'ro',
);

has postback => (
    is      => 'ro',
);

has access_token => (
    is          => 'rw',
    predicate   => 'has_access_token',
);


sub request_access_token {
    my ($self, $code) = @_;
    my $token = Facebook::Graph::AccessToken->new(
        code            => $code,
        postback        => $self->postback,
        secret          => $self->secret,
        app_id          => $self->app_id,
    )->request;
    $self->access_token($token->token);
    return $self;
}

sub set_access_token {
    my ($self, $token) = @_;
    $self->access_token($token);
    return $self;
}

sub authorize { 
    my ($self) = @_;
    return Facebook::Graph::Authorize->new(
        app_id          => $self->app_id,
        postback        => $self->postback,
    );
}

sub fetch {
    my ($self, $object_name) = @_;
    my $uri = $self->uri;
    $uri->path($object_name);
    if ($self->has_access_token) {
        $uri->query_form(
            access_token    => $self->access_token,  
        );
    }
    my $content = LWP::UserAgent->new->get($uri->as_string)->content;
    return JSON->new->decode($content);
}

sub query {
    my ($self) = @_;
    my %params;
    if ($self->has_access_token) {
        $params{access_token} = $self->access_token;
    }
    return Facebook::Graph::Query->new(%params);
}


no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph - An interface to the Facebook Graph API.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;
 my $sarah_bownds = $fb->fetch('sarahbownds');
 my $perl_page = $fb->fetch('16665510298');
 
Or better yet:

 my $sarah_bownds = $fb->query
    ->find('sarahbownds')
    ->include_metadata
    ->select_fields(qw( id name picture ))
    ->request
    ->as_hashref;
 
 
=head2 Building A Privileged App

 my $fb = Facebook::Graph->new(
    app_id          => $facebook_application_id,
    secret          => $facebook_application_secret,
    postback        => 'https://www.yourapplication.com/facebook/oauth/postback',
 );

Get the user to authorize your app (only needed if you want to fetch non-public information or publish stuff):

 my $uri = $fb
    ->authorize
    ->add_permissions(qw(offline_access publish_stream))
    ->uri_as_string;

 # redirect the user's browser to $uri

Handle the Facebook authorization code postback:

 my $q = Plack::Request->new($env);
 $fb->request_access_token($q->query_param('code'));
 
Or if you already had the access token:

 $fb->set_access_token($token);
 
Get some info:

 my $user = $fb->fetch('me');
 my $friends = $fb->fetch('me/friends');
 my $sarah_bownds = $fb->fetch('sarahbownds');

=head1 DESCRIPTION

This is a Perl interface to the Facebook Graph API L<http://developers.facebook.com/docs/api>.

B<WARNING:> This module is experimental at best. The work on it has only just begun because the Graph API itself isn't very new. Therefore things are subject to change drastically with each release, and it may fail to work entirely.




=head1 TODO

Basically everything. It has hardly any tests, very little documentation, and very little functionality in it's present form.


=head1 METHODS

See the SYNOPSIS for the time being.

B<NOTE:> The C<fetch> method is quick and dirty. Consider using C<query> (L<Facebook::Graph::Query>) instead.

=head1 PREREQS

L<Moose>
L<JSON>
L<LWP>
L<URI>
L<Crypt::SSLeay>

=head1 SUPPORT

=over

=item Repository

L<http://github.com/rizen/Facebook-Graph>

=item Bug Reports

L<http://github.com/rizen/Facebook-Graph/issues>

=back


=head1 SEE ALSO

If you're looking for a fully featured Facebook client in Perl I highly recommend L<WWW::Facebook:API>. It does just about everything, it just uses the old Facebook API.

=head1 AUTHOR

JT Smith <jt_at_plainblack_dot_com>

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


