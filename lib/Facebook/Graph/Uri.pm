use strict;
use warnings;
package Facebook::Graph::Uri;

use Moose;
use parent 'URI';

sub BUILD {
    my ($self) = @_;
    $self->scheme('https');
    $self->host('graph.facebook.com');
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

=head1 NAME

Facebook::Graph::Uri - The base URI for the Facebook Graph API.

=head1 DESCRIPTION

Is a subclass of L<URI> with the scheme and host already filled in for the Facebook Graph API. Generally you never need to do anything with this module, it is used by the other modules in L<Facebook::Graph>.

=cut


