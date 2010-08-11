package Facebook::Graph::Publish::RSVPDeclined;

use Any::Moose;
extends 'Facebook::Graph::Publish';

use constant object_path => '/declined';

no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::RSVPDeclined - RSVP declined to an event.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->rsvp_declined($event_id)
    ->publish;

=head1 DESCRIPTION

RSVP's "Declined" to an event.

B<ATTENTION:> You must have the C<rsvp_event> privilege to use this module.

=head1 METHODS


=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain a string of either 'true' or 'false'.

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
