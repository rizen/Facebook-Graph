package Facebook::Graph::Publish::Comment;

use Any::Moose;
extends 'Facebook::Graph::Publish';

use constant object_path => '/comments';

has message => (
    is          => 'rw',
    predicate   => 'has_message',
);

sub set_message {
    my ($self, $message) = @_;
    $self->message($message);
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
    return $post;
};


no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Comment - Publish a comment on a post.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_comment($comment_id)
    ->set_message('Why so serious?')
    ->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish comments on posts.

B<ATTENTION:> You must have the C<publish_stream> privilege to use this module.

=head1 METHODS

=head2 set_message ( message )

Sets the text to post to the wall.

=head3 message

A string of text.



=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
