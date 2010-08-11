package Facebook::Graph::Publish::Link;

use Any::Moose;
extends 'Facebook::Graph::Publish';

use constant object_path => '/links';

has message => (
    is          => 'rw',
    predicate   => 'has_message',
);

sub set_message {
    my ($self, $message) = @_;
    $self->message($message);
    return $self;
}

has link_uri => (
    is          => 'rw',
    predicate   => 'has_link_uri',
);

sub set_link_uri {
    my ($self, $link_uri) = @_;
    $self->link_uri($link_uri);
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
    if ($self->has_link_uri) {
        $post->{link} = $self->link_uri;
    }
    return $post;
};


no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Link - Add a link.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_link
    ->set_link_uri('http://www.plainblack.com')
    ->set_message('Plain Black')
    ->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish notes.

B<ATTENTION:> You must have the C<publish_stream> privilege to use this module.

=head1 METHODS

=head2 to ( id )

Specify a profile id to post to. Defaults to 'me', which is the currently logged in user.


=head2 set_message ( message )

Sets the description of the link.

=head3 message

A string of text.


=head2 set_link_uri ( uri )

Sets the URI to link to.

=head3 uri

A a URI.



=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
