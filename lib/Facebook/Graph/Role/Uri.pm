package Facebook::Graph::Role::Uri;

use Moose::Role;
use URI;

sub uri {
    return URI->new('https://graph.facebook.com')
}


no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Facebook::Graph::Uri - The base URI for the Facebook Graph API.

=head1 DESCRIPTION

Is a subclass of L<URI> with the scheme and host already filled in for the Facebook Graph API. Generally you never need to do anything with this module, it is used by the other modules in L<Facebook::Graph>.

=cut


