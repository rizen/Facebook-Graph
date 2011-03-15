package Facebook::Graph::Publish::Checkin;

use Any::Moose;
extends 'Facebook::Graph::Publish';

use constant object_path => '/checkins';

has message => (
    is          => 'rw',
    predicate   => 'has_message',
);

sub set_message {
    my ($self, $message) = @_;
    $self->message($message);
    return $self;
}

has place => (
    is          => 'rw',
    predicate   => 'has_place',
);

sub set_place {
    my ($self, $value) = @_;
    $self->place($value);
    return $self;
}

has longitude => (
    is          => 'rw',
    isa         => 'Num',
    predicate   => 'has_longitude',
);

sub set_longitude {
    my ($self, $value) = @_;
    $self->longitude($value);
    return $self;
}

has latitude => (
    is          => 'rw',
    isa         => 'Num',
    predicate   => 'has_latitude',
);

sub set_latitude {
    my ($self, $value) = @_;
    $self->latitude($value);
    return $self;
}

has tags => (
    is          => 'rw',
    isa         => 'ArrayRef',
    predicate   => 'has_tags',
    lazy        => 1,
    default     => sub {[]},
);

sub set_tags {
    my ($self, $value) = @_;
    $self->tags($value);
    return $self;
}


around get_post_params => sub {
    my ($orig, $self) = @_;
    my $post = $orig->($self);
    if ($self->has_message) {
        push @$post, message => $self->message;
    }
    if ($self->has_place) {
        push @$post, place => $self->place;
    }
    if ($self->has_tags) {
        push @$post, tags => join(', ',@{$self->tags});
    }
    if ($self->has_latitude && $self->has_longitude) {
        push @$post, coordinates => JSON->new->encode({ latitude => $self->latitude, longitude => $self->longitude });
    }
   return $post;
};


no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Checkin - Publish a location checkin.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_checkin
    ->set_place(222047056390)
    ->publish;

 my $response = $fb->add_checkin
    ->set_place(222047056390)
    ->set_message('Mmm...pizza.')
    ->set_tags([qw(sarah.bownds 1647395831)])
    ->set_latitude()
    ->set_longitude()
    ->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish user checkins to locations.

B<ATTENTION:> You must have the C<user_checkins> privilege to use this module, and C<friends_checkins> to get friends checkins.

=head1 METHODS

=head2 to ( id )

Specify a profile id to post to. Defaults to 'me', which is the currently logged in user.


=head2 set_message ( message )

Sets the text to post to the wall.

=head3 message

A string of text.


=head2 set_place ( id )

Sets the id of the place you are checking in to.

=head3 id

The id of a page for a place. For example C<222047056390> is the id of Pete's Pizza and Pub in Milwaukee, WI.


=head2 set_latitude ( coord )

Sets sets the coords of your location. See also C<set_longitude>

=head3 coord

The decimal latitude of your current location.


=head2 set_longitude ( coord )

Sets sets the coords of your location. See also C<set_latitude>

=head3 coord

The decimal longitude of your current location.


=head2 set_tags ( list )

Sets the list of users at the location.

=head3 list

An array reference of Facebook user ids that are currently at this location with you.



=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
