package Facebook::Graph::Publish::Photo;

use Moo;
extends 'Facebook::Graph::Publish';

use constant object_path => '/photos';

has message => (
    is          => 'rw',
    predicate   => 'has_message',
);

sub set_message {
    my ($self, $message) = @_;
    $self->message($message);
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

has url => (
    is          => 'rw',
    predicate   => 'has_url',
);

sub set_url {
    my ($self, $url) = @_;
    $self->url($url);
    return $self;
}

around get_post_params => sub {
    my ($orig, $self) = @_;

    my $post = $orig->($self);

    if ($self->has_message) {
        push @$post, message => $self->message;
    }

    if ($self->has_url) {
        push @$post, url => [$self->url];
    } elsif ($self->has_source) {
        push @$post, source => [$self->source];
    }

    return $self->has_url ? $post : ( Content_Type => 'form-data', Content => $post );
};

1;

=head1 NAME

Facebook::Graph::Publish::Photo - Publish Photos

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_photo()
 	->set_source('/tmp/photo.jpg')
 	->set_message('Photo!')
    ->publish;

=head1 DESCRIPTION

Publish a Photo

B<ATTENTION:> You must have the C<publish_stream> privilege to use this module.

=head1 METHODS

=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain a string of either 'true' or 'false'.

=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2012 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
