package Facebook::Graph::Query;

use Any::Moose;
use Facebook::Graph::Response;
with 'Facebook::Graph::Role::Uri';
use LWP::UserAgent;
use URI::Encode qw(uri_decode);

has secret => (
    is          => 'ro',
    required    => 0,
    predicate   => 'has_secret',
);

has access_token => (
    is          => 'ro',
    predicate   => 'has_access_token',
);

has ids => (
    is          => 'rw',
    predicate   => 'has_ids',
    lazy        => 1,
    default     => sub { [] },
);

has fields => (
    is          => 'rw',
    predicate   => 'has_fields',
    lazy        => 1,
    default     => sub { [] },
);

has metadata => (
    is          => 'rw',
    predicate   => 'has_metadata',
);

has limit => (
    is          => 'rw',
    predicate   => 'has_limit',
);

has offset => (
    is          => 'rw',
    predicate   => 'has_offset',
);

has search_query => (
    is          => 'rw',
    predicate   => 'has_search_query',
);

has search_type => (
    is          => 'rw',
    predicate   => 'has_search_type',
);

has object_name => (
    is          => 'rw',
    default     => '',
);

has until => (
    is          => 'rw',
    predicate   => 'has_until',
);

has since => (
    is          => 'rw',
    predicate   => 'has_since',
);


sub limit_results {
    my ($self, $limit) = @_;
    $self->limit($limit);
    return $self;    
}

sub find {
    my ($self, $object_name) = @_;
    $self->object_name($object_name);
    return $self;
}

sub search {
    my ($self, $query, $type) = @_;
    if ($type eq 'my_news') {
        $self->object_name('me/home');
    }
    else {
        $self->object_name('search');
        $self->search_type($type);
    }
    $self->search_query($query);
    return $self;
}

sub offset_results {
    my ($self, $offset) = @_;
    $self->offset($offset);
    return $self;    
}

sub include_metadata {
    my ($self, $include) = @_;
    $include = 1 unless defined $include;
    $self->metadata($include);
    return $self;
}

sub select_fields {
    my ($self, @fields) = @_;
    push @{$self->fields}, @fields;
    return $self;
}

sub where_ids {
    my ($self, @ids) = @_;
    push @{$self->ids}, @ids;
    return $self;
}

sub where_until {
    my ($self, $date) = @_;
    $self->until($date);
    return $self;
}

sub where_since {
    my ($self, $date) = @_;
    $self->since($date);
    return $self;
}

sub uri_as_string {
    my ($self) = @_;
    my %query;
    if ($self->has_access_token) {
        $query{access_token} = uri_decode($self->access_token);
    }
    if ($self->has_limit) {
        $query{limit} = $self->limit;
        if ($self->has_offset) {
            $query{offset} = $self->offset;
        }
    }
    if ($self->has_search_query) {
        $query{q} = $self->search_query;
        if ($self->has_search_type) {
            $query{type} = $self->search_type;
        }
    }
    if ($self->has_until) {
        $query{until} = $self->until;
    }
    if ($self->has_since) {
        $query{since} = $self->since;
    }
    if ($self->has_metadata) {
        $query{metadata} = $self->metadata;
    }
    if ($self->has_fields) {
        $query{fields} = join(',', @{$self->fields});
    }
    if ($self->has_ids) {
        $query{ids} = join(',', @{$self->ids});
    }
    my $uri = $self->uri;
    $uri->path($self->object_name);
    $uri->query_form(%query);
    return $uri->as_string;
}

sub request {
    my ($self, $uri) = @_;
    $uri ||= $self->uri_as_string;
    my $response = LWP::UserAgent->new->get($uri);
    my %params = (response => $response);
    if ($self->has_secret) {
        $params{secret} = $self->secret;
    }
    return Facebook::Graph::Response->new(%params);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


=head1 NAME

Facebook::Graph::Query - Simple and fast searching and fetching of Facebook data.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;
 
 my $perl_page = $fb->find('16665510298')
    ->include_metadata
    ->request
    ->to_hashref;
 
 my $sarah_bownds = $fb->find('sarahbownds')
    ->select_fields(qw(id name))
    ->request
    ->to_hashref;

 # this one would require an access token
 my $new_car_posts = $fb->query
    ->search('car', 'my_news')
    ->where_since('yesterday')
    ->request
    ->to_hashref;


=head1 DESCRIPTION

This module presents a programatic approach to building the queries necessary to search and retrieve Facebook data. It provides an almost SQL like way of writing queries using code. For example:

 my $results = $fb
    ->select_fields(qw(id name))
    ->search('Dave','user')
    ->where_since('yesterday')
    ->limit_results(25)
    ->request
    ->to_hashref;
    
The above query, if you were read it like text, says: "Give me the user ids and full names of all users named Dave that have been created since yesterday, and limit the result set to the first 25."


=head1 METHODS

=head2 find ( id )

Fetch a single item.

=head3 id

The unique id or object name of an object.

B<Example:> For user "Sarah Bownds" you could use either her profile id C<sarahbownds> or her object id C<767598108>.




=head2 search ( query, type )

Perform a keyword search on a group of items.

=head3 query

They keywords to search by.

=head3 type

One of the following types:

=over

=item my_news

The current user's news feed (home page). Requires that you have an access_token so you know who the current user is.

=item post

All public posts.

=item user

All people.

=item page

All pages.

=item event

All events.

=item group

All groups.

=back



=head2 limit_results ( amount )

The result set will only return a certain number of records when this is set. Useful for paging result sets. Returns C<$self> for method chaining.

=head3 amount

An integer representing the number of records to be returned.



=head2 offset_results ( amount )

Skips ahead the result set by the amount. Useful for paging result sets. Is only applied when used in combination with C<limit_results>. Returns C<$self> for method chaining.

=head3 amount

An integer representing the amount to offset the results by.



=head2 include_metadata ( [ include ] )

Adds metadata to the result set including things like connections to other objects and the object type being returned. Returns C<$self> for method chaining.

=head3 include

Defaults to 1 when the method is called, but defaults to 0 if the method is never called. You may set it specifically by passing in a 1 or 0.


=head2 select_fields ( fields )

Limit the result set to only include the specific fields if they exist in the objects in the result set. Returns C<$self> for method chaining. May be called multiple times to add more fields.

=head3 fields

An array of fields you want in the result set.

B<Example:> 'id', 'name', 'picture'


=head2 where_ids ( ids )

Limit the result set to these specifically identified objects. Returns C<$self> for method chaining. May be called multiple times to add more ids.

=head3 ids

An array of object ids, object names, or URIs.

B<Example:> 'http://www.thegamecrafter.com/', 'sarahbownds', '16665510298'


=head2 where_until ( date )

Include only records that were created before C<date>. Returns C<$self> for method chaining.

=head3 date

Anything accepted by PHP's strtotime function L<http://php.net/manual/en/function.strtotime.php>.


=head2 where_since ( date )

Include only records that have been created since C<date>. Returns C<$self> for method chaining.

=head3 date

Anything accepted by PHP's strtotime function L<http://php.net/manual/en/function.strtotime.php>.


=head2 uri_as_string ()

Returns a URI string based upon all the methods you've called so far on the query. Mainly useful for debugging. Usually you want to call C<request> and have it fetch the data for you.



=head2 request ( [ uri ] )

Forms a URI string based on every method you've called so far, and fetches the data. Returns a L<Facebook::Graph::Response> object.

=head3 uri

Optionally pass in your own URI string and all the other options will be ignored. This is mainly useful with metadata connections. See C<include_metadata> for details.


=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
