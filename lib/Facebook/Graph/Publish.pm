package Facebook::Graph::Publish;

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

sub to {
    my ($self, $object_name) = @_;
    $self->object_name($object_name);
    return $self;
}

sub get_post_params {
    return {};
}

sub publish {
    my ($self) = @_;
    my $uri = $self->uri;
    $uri->path($self->object_name.$self->object_path);
    my $response = LWP::UserAgent->new->post($uri, $self->get_post_params);
    my %params = (response => $response);
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Response->new(%params);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish - A base class for publishing various things to facebook.

=head1 DESCRIPTION

This module shouldn't be used by you directly for any purpose. 

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
