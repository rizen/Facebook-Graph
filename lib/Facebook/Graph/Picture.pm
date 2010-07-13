package Facebook::Graph::Picture;

use Any::Moose;
with 'Facebook::Graph::Role::Uri';

has type => (
    is          => 'rw',
    predicate   => 'has_type',
);

has object_name => (
    is          => 'rw',
    default     => '',
);

sub get_small {
    my ($self) = @_;
    $self->type('small');
    return $self;
}

sub get_square {
    my ($self) = @_;
    $self->type('square');
    return $self;
}

sub get_large {
    my ($self) = @_;
    $self->type('large');
    return $self;
}

sub uri_as_string {
    my ($self) = @_;
    my %query;
    if ($self->has_type) {
        $query{type} = $self->type;
    }
    my $uri = $self->uri;
    $uri->path($self->object_name . '/picture');
    $uri->query_form(%query);
    return $uri->as_string;
}


no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Picture - Get the URI for the picture of any object.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;
 
 my $default_picture =  $fb->picture('16665510298')->uri_as_string;
 my $large_picture = $fb->picture('16665510298')->get_large->uri_as_string;
 my $small_picture = $fb->picture('16665510298')->get_small->uri_as_string;
 my $square_picture = $fb->picture('16665510298')->get_square->uri_as_string;

=head1 DESCRIPTION

This module allows you to generate the URL needed to fetch a picture for any object on Facebook.

=head1 METHODS


=head2 get_large ( id )

Get a large picture. 200 pixels wide by a variable height.

=head3 id

The unique id or object name of an object.

B<Example:> For user "Sarah Bownds" you could use either her profile id C<sarahbownds> or her object id C<767598108>.


=head2 get_small ( id )

Get a small picture. 50 pixels wide by a variable height.

=head3 id

The unique id or object name of an object.

B<Example:> For user "Sarah Bownds" you could use either her profile id C<sarahbownds> or her object id C<767598108>.


=head2 get_square ( id )

Get a square picture. 50 pixels wide by 50 pixels tall.

=head3 id

The unique id or object name of an object.

B<Example:> For user "Sarah Bownds" you could use either her profile id C<sarahbownds> or her object id C<767598108>.




=head2 uri_as_string ()

Returns a URI string based upon all the methods you've called so far on the query. You can throw the resulting URI right into an <img> tag.


=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
