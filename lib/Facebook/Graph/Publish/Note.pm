package Facebook::Graph::Publish::Note;

use Any::Moose;
extends 'Facebook::Graph::Publish';

use constant object_path => '/notes';

has message => (
    is          => 'rw',
    predicate   => 'has_message',
);

sub set_message {
    my ($self, $message) = @_;
    $self->message($message);
    return $self;
}

has subject => (
    is          => 'rw',
    predicate   => 'has_subject',
);

sub set_subject {
    my ($self, $subject) = @_;
    $self->subject($subject);
    return $self;
}



around get_post_params => sub {
    my ($orig, $self) = @_;
    my $post = $orig->($self);
    if ($self->has_access_token) {
        $post->{access_token} = $self->access_token;
    }
    if ($self->has_message) {
        $post->{message} = $self->message;
    }
    if ($self->has_subject) {
        $post->{subject} = $self->subject;
    }
    return $post;
};


no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Note - Add a note to a user's list of notes.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_note
    ->set_subject('Things I Like')
    ->set_message('I like beer.')
    ->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish notes.

B<ATTENTION:> You must have the C<publish_stream> privilege to use this module.

=head1 METHODS

=head2 to ( id )

Specify a profile id to post to. Defaults to 'me', which is the currently logged in user.


=head2 set_message ( message )

Sets the body text of the note.

=head3 message

A string of text.


=head2 set_subject ( subject )

Sets the title to identify the note from others.

=head3 subject

A string of text.



=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
