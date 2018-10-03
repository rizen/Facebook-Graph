package Facebook::Graph::Publish;

use Moo;
use Facebook::Graph::Request;
with 'Facebook::Graph::Role::Uri';
use LWP::UserAgent;
use URI::Escape;

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

sub to {
    my ($self, $object_name) = @_;
    $self->object_name($object_name);
    return $self;
}

sub get_post_params {
    my $self = shift;
    my @post;
    if ($self->has_access_token) {
        push @post, access_token => uri_unescape($self->access_token);
    }
    return \@post;
}

sub publish {
    my ($self) = @_;
    my $uri = $self->uri;
    $uri->path($self->generate_versioned_path($self->object_name.$self->object_path));
    return Facebook::Graph::Request->new->post($uri, $self->get_post_params);
}

1;

=head1 NAME

Facebook::Graph::Publish - A base class for publishing various things to facebook.

=head1 DESCRIPTION

This module shouldn't be used by you directly for any purpose. 

=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2017 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
