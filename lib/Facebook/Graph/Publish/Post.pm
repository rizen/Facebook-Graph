package Facebook::Graph::Publish::Post;

use Any::Moose;
extends 'Facebook::Graph::Publish';

use constant object_path => '/feed';

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
    $self->picture_uri($picture);
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

has target_countries => (
    is          => 'rw',
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_countries',
);

sub set_target_countries {
    my ($self, $source) = @_;
    $self->target_countries($source);
    return $self;
}

has target_cities => (
    is          => 'rw',
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_cities',
);

sub set_target_cities {
    my ($self, $source) = @_;
    $self->target_cities($source);
    return $self;
}

has target_regions => (
    is          => 'rw',
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_regions',
);

sub set_target_regions {
    my ($self, $source) = @_;
    $self->target_regions($source);
    return $self;
}

has target_locales => (
    is          => 'rw',
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_target_locales',
);

sub set_target_locales {
    my ($self, $source) = @_;
    $self->target_locales($source);
    return $self;
}

has source => (
    is          => 'rw',
    predicate   => 'has_source',
);

sub set_source {
    my ($self, $source) = @_;
    $self->source($source);
    return $self;
}

has actions => (
    is          => 'rw',
    lazy        => 1,
    isa         => 'ArrayRef',
    predicate   => 'has_actions',
);

sub set_actions {
    my ($self, $actions) = @_;
    $self->actions($actions);
    return $self;
}

sub add_action {
    my ($self, $name, $link) = @_;
    my $actions = $self->actions;
    push @$actions, { name => $name, link => $link };
    $self->actions($actions);
    return $self;
}

has privacy => (
    is          => 'rw',
    predicate   => 'has_privacy',
);

has privacy_options => (
    is          => 'rw',
    isa         => 'HashRef',
);

sub set_privacy {
    my ($self, $privacy, $options) = @_;
    $self->privacy($privacy);
    $self->privacy_options($options);
    return $self;
}

around get_post_params => sub {
    my ($orig, $self) = @_;
    my $post = $orig->($self);
    if ($self->has_message) {
        push @$post, {message => $self->message };
    }
    if ($self->has_link_uri) {
        push @$post, {link => $self->link_uri};
    }
    if ($self->has_link_name) {
        push @$post, {name => $self->link_name};
    }
    if ($self->has_link_caption) {
        push @$post, {caption => $self->link_caption};
    }
    if ($self->has_link_description) {
        push @$post, {description => $self->link_description};
    }
    if ($self->has_picture_uri) {
        push @$post, {picture => $self->picture_uri};
    }
    if ($self->has_source) {
        push @$post, {source => $self->source};
    }
    if ($self->has_actions) {
        foreach my $action (@{$self->actions}) {
            push @$post, JSON->new->encode($action);
        }
    }
    if ($self->has_privacy) {
        my %privacy = %{$self->privacy_options};
        $privacy{value} = $self->privacy;
        push @$post, {privacy => JSON->new->encode(\%privacy)};
    }
    return $post;
};


no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Post - Publish to a user's wall.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_post
    ->set_message('I like beer.')
    ->publish;

 my $response = $fb->add_post
    ->set_message('I like Perl.')
    ->set_picture_uri('http://www.perl.org/i/camel_head.png')
    ->set_link_uri('http://www.perl.org/')
    ->set_link_name('Perl.org')
    ->set_link_caption('Perl is a programming language.')
    ->set_link_description('A link to the Perl web site.')
    ->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish to a user's Facebook feed.

B<ATTENTION:> You must have the C<publish_stream> privilege to use this module.

B<TIP:> Facebook seems to use these terms interchangibly: Feed, Post, News, Wall. So if you want to publish to a user's wall, this is the mechanism you use to do that.

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


=head2 set_source ( uri )

Sets a source URI for a flash or video file.

=head3 uri

The URI you wish to set. For example if you wanted to include a YouTube video:

 $post->set_source('http://www.youtube.com/watch?v=efsJRdJ6dog');


=head2 set_actions ( actions )

Sets a list of actions (or links) that should go in the post as things people can do with the post. This allows for integration of the post with third party sites.

=head3 actions

An array reference of hash references containing C<name> / C<link> pairs.

 $post->actions([
    {
        name    => 'Click Me!',
        link    => 'http://www.somesite.com/click',
    },
    ...
 ]);

=head2 add_action ( name, link )

Adds an action to the list of actions set either by previously calling C<add_action> or by calling C<set_actions>.

=head3 name

The name of the action (the clickable label).

=head3 link

The URI of the action.



=head2 set_privacy ( setting, options )

A completely optional privacy setting. 

=head3 setting

The privacy setting. Choose from: EVERYONE, CUSTOM, ALL_FRIENDS, NETWORKS_FRIENDS, and FRIENDS_OF_FRIENDS. See L<http://developers.facebook.com/docs/reference/api/post> for changes in this list.

=head3 options

A hash reference of options to tweak the privacy setting. Some options are required depending on what privacy setting you chose. See L<http://developers.facebook.com/docs/reference/api/post> for details.

 $post->set_privacy('CUSTOM', { friends => 'SOME_FRIENDS', allow => [qw( 119393 993322 )] });

=over

=item friends

A string that must be one of EVERYONE, NETWORKS_FRIENDS, FRIENDS_OF_FRIENDS, ALL_FRIENDS, SOME_FRIENDS, SELF, or NO_FRIENDS.

=item networks

An array reference of network ids.

=item allow

An array reference of user ids.

=item deny.

An array reference of user ids.

=back


=head2 set_target_countries ( countries )

Makes a post only available to viewers in certain countries.

 $post->set_target_countries( ['US'] );
 
=head3 countries

An array reference of two letter country codes (upper case). You can find a list of country codes in the list of city ids here: L<http://developers.facebook.com/attachment/all_cities_final.csv>.


=head2 set_target_regions ( regions )

Makes a post only available to viewers in certain regions.

 $post->set_target_regions( [6,53] );
 
=head3 regions

An array reference of region numbers however Facebook defines that. I've got no idea because their documentation sucks. I'm not even sure what a region is. Is it a region of a country? Of a continent? No idea. I do know it is an integer, but that's about it.



=head2 set_target_cities ( cities )

Makes a post only available to viewers in certain cities.

 $post->set_target_cities( [2547804] );
 
=head3 cities

An array reference of cities ids. In the example above I've listed Madison, WI. You can find a list of their cities here: L<http://developers.facebook.com/attachment/all_cities_final.csv>



=head2 set_target_locales ( locales )

Makes a post only available to viewers in certain locales.

 $post->set_target_locales( [6] );
 
=head3 locales

An array reference of locales ids. You can find their list of locales here: L<http://developers.facebook.com/attachment/locales_final.csv>



=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
