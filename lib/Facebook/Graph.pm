use strict;
use warnings;
package Facebook::Graph;

use Moose;
use Facebook::Graph::AccessToken;
use Facebook::Graph::Authorize;
use Facebook::Graph::Uri;
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
    my $url = Facebook::Graph::Uri->new;
    $url->path($object_name);
    if ($self->has_access_token) {
        $url->query_form(
            access_token    => $self->access_token,  
        );
    }
    return JSON->new->parse(
        LWP::UserAgent->new->get($url->as_string)->content
    );
}


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

=head1 NAME

Facebook::Graph - An interface to the Facebook Graph API.

=head1 SYNOPSIS

Getting started:

 my $fb = Facebook::Graph->new(
    app_id          => $facebook_application_id,
    secret          => $facebook_application_secret,
    postback        => 'https://www.yourapplication.com/facebook/oauth/postback',
 );

Get the user to authorize your app (only needed if you want to fetch non-public information or publish stuff):

 my $url = $fb
    ->authorize
    ->add_permissions(qw(offline_access publish_stream))
    ->to_url;

 # redirect the user's browser to $url

Handle the Facebook authorization code postback:

 my $q = Plack::Request->new($env);
 $fb->request_access_token($q->query_param('code'));
 
Or if you already had the access token:

 $fb->set_access_token($token);
 
Or you can go without an access token and just get public information.

Get some info:

 my $user = $fb->fetch('me');
 my $friends = $fb->fetch('me/friends');
 my $sarah_bownds = $fb->fetch('sarahbownds);

=head1 DESCRIPTION

This is a Perl interface to the Facebook Graph API L<http://developers.facebook.com/docs/api>.

B<WARNING:> This module is experimental at best. The work on it has only just begun because the Graph API itself isn't very new. Therefore things are subject to change drastically with each release, and it may fail to work entirely.

=head1 TODO

Basically everything. It has no tests, very little documentation, and very little functionality in it's present form.


=head1 METHODS

See the SYNOPSIS for the time being.

B<NOTE:> The C<fetch> method will likely go away and be replaced by individual object types. I just needed something quick and dirty for the time being to see that it works.

=head1 PREREQS

L<Moose>
L<JSON>
L<LWP>
L<URI>

=head1 SUPPORT

=over

=item Repository

L<http://github.com/plainblack/Facebook-Graph>

=item Bug Reports

L<http://github.com/plainblack/Facebook-Graph/issues>

=back


=head1 SEE ALSO

If you're looking for a fully featured Facebook client in Perl I highly recommend L<WWW::Facebook:API>. It does just about everything, it just uses the old Facebook API.

=head1 AUTHOR

JT Smith <jt_at_plainblack_dot_com>

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


