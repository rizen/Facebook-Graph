package Facebook::Graph::Page::Feed;
use strict;
$Facebook::Graph::Page::Feed::VERSION = '1.0700';
use Moo;
extends 'Facebook::Graph::Publish';

has page_id => (
	is => 'rw',
	predicate => 'has_page_id',
);

sub set_page_id {
	my ($self, $page_id) = @_;
	$self->object_name(''); # not sure it's a good way here
	$self->set_published(1); # it's a default value on FB side;
	$self->page_id($page_id);
	return $self;
}

use subs qw(object_path);
sub object_path{
	my $s = shift;
	
	return $s->has_page_id ? 
		sprintf( '%s/feed', $s->page_id )
		: die "You must set_page_id first";
}

has message => (
	is          => 'rw',
	predicate   => 'has_message',
);

sub set_message {
	my ($self, $message) = @_;
	$self->message($message);
	return $self;
}

has link_uri => (
	is          => 'rw',
	predicate   => 'has_link_uri',
);

sub set_link_uri {
	my ($self, $link_uri) = @_;
	$self->link_uri($link_uri);
	return $self;
}

has backdated_time => (
	is			=> 'rw',
	predicate	=> 'has_backdated_time',
);

sub set_backdated_time
{
	my ($self, $backdated_time) = @_;
	$self->backdated_time($backdated_time);
	return $self;
}

has scheduled_publish_time => (
	is			=> 'rw',
	predicate	=> 'has_scheduled_publish_time'
);

sub set_scheduled_publish_time
{
	my ($self, $scheduled_publish_time) = @_;
	$self->scheduled_publish_time($scheduled_publish_time);
	return $self;
}

has published => (
	is			=> 'rw',
	predicate	=> 'has_published',
	reader		=> '_get_published',
	writer		=> '_set_published',
);

sub published
{
	my($self, $published) = @_;
	
	if( scalar @_ > 1 )
	{
		$self->_set_published($published);
	}
	
	return $self->_get_published && $self->_get_published ne 'false';
}

sub set_published
{
	my ($self, $published) = @_;
	$self->published($published);
	return $self;
}

around get_post_params => sub {
	my ($orig, $self) = @_;
	my $post = $orig->($self);
	if ($self->has_message) {
		push @$post, message => $self->message;
	}
	if ($self->has_link_uri) {
		push @$post, link => $self->link_uri;
	}
	if ($self->has_backdated_time) {
		push @$post, backdated_time => $self->backdated_time + 10*3600; # temporary fix for FB::Graph API
	}
	if (
		$self->has_scheduled_publish_time
		and (
			not $self->has_published or not $self->published
		)
		) {
		push @$post, scheduled_publish_time => $self->scheduled_publish_time;
	}
	if ($self->has_published) {
		push @$post, published => $self->published ? 'true': 'false';
	}
	return $post;
};

1;

=head1 NAME

Facebook::Graph::Page::Feed - Add a post to a Facebook page.

=head1 SYNOPSIS

 my $fb = Facebook::Graph->new;

 $fb->add_page_feed
	->set_page_id($page_id)
	->set_message('This is a test post')
	->set_backdated_time(time-3600)
	->set_scheduled_publish_time(time+3600)
	->set_published('false')
	->set_link_uri('http://mysite.com/testpage')
	->publish;


=head1 DESCRIPTION

This module gives you quick and easy access to publish posts on FB pages.

Implements publishing protocol available here:
L<https://developers.facebook.com/docs/graph-api/reference/v2.0/page/feed/>

B<ATTENTION:> You must have the page access token to use this module.
It's available in C<$fb->fetch('me/accounts')>, but, you must have a user 
token with C<manage_page> permission.

More information about tokens could be found here: 
L<https://developers.facebook.com/docs/facebook-login/access-tokens>

=head1 METHODS

=head2 set_page_id ( page_id )

Specify a page id to post to. This is required field and must be set before 
publishing.

=head2 set_message ( message )

Sets the description of the link.

=head3 message

A string of text.


=head2 set_link_uri ( uri )

Sets the URI to link to.

=head3 uri

A URI.

=head2 set_backdated_time ( time )

Set a date of your post, different from now. Just a backdate. Time should be a 
timestamp, no fancy formats.

=head2 set_scheduled_publish_time( time )

Set a publishing time for scheduled posts. Time should be a desired timestamp of 
post in future. Doesn't work with minutes from now, but works fine with hour+

=head2 publish ( )

Posts the data and returns a L<Facebook::Graph::Response> object. The response object should contain the id:

 {"id":"1647395831_130068550371568"}

 
=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2012 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

Facebook::Graph::Page::Feed is Copyright 2014 Alexandr Evstigneev (L<http://evstigneev.com>) and is licensed under the same terms as Perl itself.

=cut
