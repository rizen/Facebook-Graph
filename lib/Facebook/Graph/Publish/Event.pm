package Facebook::Graph::Publish::Event;

use Any::Moose;
extends 'Facebook::Graph::Publish';
use DateTime;
use DateTime::Format::Strptime;

use constant object_path => '/events';

has name => (
    is          => 'rw',
    predicate   => 'has_name',
);

sub set_name {
    my ($self, $input) = @_;
    $self->name($input);
    return $self;
}

has description => (
    is          => 'rw',
    predicate   => 'has_description',
);

sub set_description {
    my ($self, $input) = @_;
    $self->description($input);
    return $self;
}

has location => (
    is          => 'rw',
    predicate   => 'has_location',
);

sub set_location {
    my ($self, $input) = @_;
    $self->location($input);
    return $self;
}

has start_time => (
    is          => 'rw',
    isa         => 'DateTime',
    predicate   => 'has_start_time',
);

sub set_start_time {
    my ($self, $start_time) = @_;
    $self->start_time($start_time);
    return $self;
}

has end_time => (
    is          => 'rw',
    isa         => 'DateTime',
    predicate   => 'has_end_time',
);

sub set_end_time {
    my ($self, $end_time) = @_;
    $self->end_time($end_time);
    return $self;
}



around get_post_params => sub {
    my ($orig, $self) = @_;
    my $post = $orig->($self);
    if ($self->has_access_token) {
        $post->{access_token} = $self->access_token;
    }
    if ($self->has_name) {
        $post->{name} = $self->name;
    }
    if ($self->has_description) {
        $post->{description} = $self->description;
    }
    if ($self->has_location) {
        $post->{location} = $self->location;
    }
    my $strp = DateTime::Format::Strptime->new(pattern => '%FT %T%z');
    if ($self->has_start_time) {
        $post->{start_time} = $strp->format_datetime($self->start_time);
    }
    if ($self->has_end_time) {
        $post->{end_time} = $strp->format_datetime($self->end_time);
    }
    return $post;
};


no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Event - Add an event.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 my $start = DateTime->new( month=>10, day=>31, year => 2010, hour=>20 );
 $fb->add_event
    ->set_start_time($start)
    ->set_end_time($start->clone->add(hours => 6))
    ->set_name('Halloween Party')
    ->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish events.

B<ATTENTION:> You must have the C<create_event> privilege to use this module.

=head1 METHODS

=head2 to ( id )

Specify a profile id to post to. Defaults to 'me', which is the currently logged in user.


=head2 set_name ( name )

Sets the name of the event.

=head3 name

A string of text.


=head2 set_description ( description )

Sets the description of the event. Tell people what's going on.

=head3 description

A string of text.


=head2 set_location ( location )

Sets a general description of where the event will take place.

=head3 location

A string of text.


=head2 set_start_time ( datetime )

Sets the start of the event.

=head3 datetime

A L<DateTime> object.


=head2 set_end_time ( datetime )

Sets the end of the event.

=head3 datetime

A L<DateTime> object.


=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}
 
 
=head1 TODO

Add venue and privacy as described on L<http://developers.facebook.com/docs/reference/api/event>.

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
