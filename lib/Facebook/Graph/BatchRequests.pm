package Facebook::Graph::BatchRequests;

use Moo;
use Ouch;
use Facebook::Graph::Request;

has access_token => (
    is          => 'ro',
    required    => 1,
);

has requests => (
    is          => 'rw',
    isa         => sub { ouch(442,"$_[0] is not an Array Reference") unless ref $_[0] eq 'ARRAY' },
    default     => sub { [] },
);

sub add_request {
    my ($self, $ele) = @_;

    unless (ref $ele eq 'HASH') {
        $ele = { method => 'GET', relative_url => $ele };
    }
    $self->requests( [ @{$self->requests}, $ele ] );

    return $self; # chained
}

sub request {
    my ($self, @reqs) = @_;

    $self->add_request($_) foreach @reqs;

    my $json = JSON->new;
    my $post = {
        access_token => $self->access_token, # required
        batch => $json->encode($self->requests),
    };

    $self->requests([]); # reset

    my $uri = "https://graph.facebook.com";
    my $resp = Facebook::Graph::Request->new->post($uri, $post)->response;

    unless ($resp->is_success) {
        my $message = $resp->message;
        my $error = eval { $json->decode($resp->content) };
        unless ($@) {
            $message = $error->{error}{type} . ' - ' . $error->{error}{message};
        }
        ouch $resp->code, "Could not execute batch requests: $message";
    }

    my $data = $json->decode($resp->decoded_content);
    map { $_->{data} = $json->decode($_->{body}) } @$data;
    return wantarray ? @$data : $data;
}

1;

=head1 NAME

Facebook::Graph::BatchRequests - Batch Requests

=head1 SYNOPSIS

    # set access_token, required
    my $fb = Facebook::Graph->new(access_token => $access_token);
    my @batches = $fb->batch_requests
        ->add_request('sarahbownds')
        ->add_request({"method" => "POST", "relative_url" => 'me/feed', body => "message=Test update"})
        ->request;

    foreach my $batch (@batches) {
        print $batch->{code} . $batch->{body} . Dumper(\$batch->{data}, \$batch->{headers}) . "\n";
    }

=head1 DESCRIPTION

send batch requests to save time: L<http://developers.facebook.com/docs/reference/api/batch/>

=head1 METHODS

=head2 new ( [ params ] )

=over

=item params

A hash or hashref of parameters to pass to the constructor.

=over

=item access_token

An access token string used to make Facebook requests as a privileged user.

=back

=back

=head2 add_request

add request, if not HASHREF, will default method as GET and arg as relative_url

    $batch_requests->add_request('sarahbownds'); # as { method => 'GET', relative_url => 'sarahbownds' }
    $batch_requests->add_request({"method" => "POST", "relative_url" => 'me/feed', body => "message=Test update"})

=head2 request

    $batch_requests->request;
    $batch_requests->request(@requests);

Fire the request and return decoded @batches data

=head1 LEGAL

Facebook::Graph is Copyright 2010 - 2017 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut
