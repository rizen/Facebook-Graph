package Facebook::Graph::Role::Uri;

use Any::Moose 'Role';
use URI;

sub uri {
    return URI->new('https://graph.facebook.com')
}


1;

=head1 NAME

Facebook::Graph::Role::Uri - The base URI for the Facebook Graph API.

=head1 DESCRIPTION

Provides a C<uri> method in any class which returns a L<URI> object that points to the Facebook Graph API. 

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut


