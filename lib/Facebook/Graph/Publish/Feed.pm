package Facebook::Graph::Publish::Feed;

use Any::Moose;
use Facebook::Graph::Response;
with 'Facebook::Graph::Role::Uri';
use LWP::UserAgent;

has secret => (
    is          => 'ro',
    required    => 0,
    predicate   => 'has_secret',
);

has access_token => (
    is          => 'ro',
    predicate   => 'has_access_token',
);

has object_name => (
    is          => 'rw',
    default     => 'me',
);

has message => (
    is          => 'rw',
    predicate   => 'has_message',
);

sub set_message {
    my ($self, $message) = @_;
    $self->message($message);
    return $self;
}


has picture_uri => (
    is          => 'rw',
    predicate   => 'has_picture_uri',
);

sub set_picture_uri {
    my ($self, $picture) = @_;
    $self->picture($picture);
    return $self;
}


has link_uri => (
    is          => 'rw',
    predicate   => 'has_link_uri',
);

sub set_link_uri {
    my ($self, $source) = @_;
    $self->link_uri($source);
    return $self;
}


has link_name => (
    is          => 'rw',
    predicate   => 'has_link_name',
);

sub set_link_name {
    my ($self, $source) = @_;
    $self->link_name($source);
    return $self;
}


has link_caption => (
    is          => 'rw',
    predicate   => 'has_link_caption',
);

sub set_link_caption {
    my ($self, $source) = @_;
    $self->link_caption($source);
    return $self;
}


has link_description => (
    is          => 'rw',
    predicate   => 'has_link_description',
);

sub set_link_description {
    my ($self, $source) = @_;
    $self->link_description($source);
    return $self;
}



sub to {
    my ($self, $object_name) = @_;
    $self->object_name($object_name);
    return $self;
}

sub publish {
    my ($self) = @_;
    my %post;
    if ($self->has_access_token) {
        $post{access_token} = $self->access_token;
    }
    if ($self->has_message) {
        $post{message} = $self->message;
    }
    if ($self->has_link_uri) {
        $post{link} = $self->link_uri;
    }
    if ($self->has_link_name) {
        $post{name} = $self->link_name;
    }
    if ($self->has_link_caption) {
        $post{caption} = $self->link_caption;
    }
    if ($self->has_link_description) {
        $post{description} = $self->link_description;
    }
    if ($self->has_picture_uri) {
        $post{picture} = $self->picture_uri;
    }
    my $uri = $self->uri;
    $uri->path($self->object_name.'/feed');
    my $response = LWP::UserAgent->new->post($uri, \%post);
    my %params = (response => $response);
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Response->new(%params);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Feed - Publish to a user's wall.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->publish_feed
    ->message('I like beer.')
    ->publish;

 my $response = $fb->publish_feed
    ->message('I like Perl.')
    ->set_picture_uri('http://www.perl.org/i/camel_head.png')
    ->set_link_uri('http://www.perl.org/')
    ->set_link_name('Perl.org')
    ->set_link_caption('Perl is a programming language.')
    ->set_description('A link to the Perl web site.')
    ->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish to a user's Facebook feed.

B<NOTE:> Facebook seems to use these terms interchangibly: Feed, News, Wall. So if you want to publish to a user's wall, this is the mechanism you use to do that.

=head1 METHODS

=head2 to ( id )

Specify a profile id to post to. Defaults to 'me', which is the currently logged in user.


=head2 set_message ( message )

Sets the text to post to the wall.

=head3 message

A string of text.


=head2 set_picture_uri ( uri )

Sets the URI of a picture to be displayed in the message.

=head3 uri

A URI to a picture.


=head2 set_link_uri ( uri )

Sets the URI of a link that viewers can click on for more information about whatever you posted in C<set_message>.

=head3 uri

A URI to a site.


=head2 set_link_name ( name )

If you want to give the link you set in C<set_link_uri> a human friendly name, use this method.

=head2 name

A text string to be used as the name of the link.


=head2 set_link_caption ( caption )

Sets a short blurb to be displayed below the link/picture.

=head3 caption

A text string.


=head2 set_link_description ( description )

Sets a longer description of the site you're linking to. Can also be a portion of the article you're linking to.

=head3 description

A text string.


=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id of the message:

 {"id":"1647395831_130068550371568"}

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
