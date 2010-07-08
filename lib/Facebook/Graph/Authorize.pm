use strict;
use warnings;
package Facebook::Graph::Authorize;

use Moose;
use Facebook::Graph::Uri;

has app_id => (
    is      => 'ro',
    required=> 1,
);

has redirect_uri => (
    is      => 'ro',
    required=> 1,
);

has scope => (
    is      => 'rw',
    default => sub { [] },
);

# http://developers.facebook.com/docs/authentication/permissions
sub extend_scope {
    my ($self, @permissions) = @_;
    push @{$self->scope}, @permissions;
    return $self;
}

sub to_url {
    my ($self) = @_;
    return Facebook::Graph::Uri->new
        ->path('/oauth/authorize')
        ->query_form(
            client_id       => $self->app_id,
            redirect_uri    => $self->redirect_uri,
            scope           => join(',', @{$self->scope})
        )
        ->as_string;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
