use strict;
use warnings;
package Facebook::Graph::Uri;

use Moose;
use parent 'URI';

sub BUILD {
    my ($self) = @_;
    $self->scheme('https:');
    $self->host('graph.facebook.com');
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
