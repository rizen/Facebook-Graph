package Facebook::Graph::Publish::Like;

use Any::Moose;
extends 'Facebook::Graph::Publish';

use constant object_path => '/likes';

no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Publish::Like - Mark a post as something you like.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_like($post_id)
    ->publish;

=head1 DESCRIPTION

Marks a post as something you like.

B<ATTENTION:> You must have the C<publish_stream> privilege to use this module.

B<BUG:> Facebook keeps telling me I don't have privileges to like anything, so I'm not sure if there's something hosed with my account or my interpretation of their API. If someone figures out how to make this work, let me know and I'll update the API to make it work.

=head1 METHODS


=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}

=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
