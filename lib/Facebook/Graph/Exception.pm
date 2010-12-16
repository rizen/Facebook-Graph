package Facebook::Graph::Exception;


use Exception::Class (
 
    'Facebook::Graph::Exception::General' => {
        description     => "A general exception has occured.",
    },

    'Facebook::Graph::Exception::RPC' => {
        isa             => 'Facebook::Graph::Exception::General',
        description     => "An error occurred communicating with Facebook.",
        fields          => [qw(http_code http_message facebook_message facebook_type uri)],
    },
 
 
);


1;



=head1 NAME

Facebook::Graph::Exception - The exceptions thrown by this module.

=head1 Description

Facebook::Graph throws exceptions when it encounters a problem. All exceptions are derived from L<Exception::Class>.

If you don't plan on using exceptions to trap problems, you can very easily just trap them like a normal C<die> like this:

 eval { $fb->do_something };
 if ($@) {
    say "An error occurred with the following message: ". $@;
 }

=head1 EXCEPTIONS

=head2 Facebok::Graph::Exception::General

A general purpose exception. No special methods. Example:

 eval { $fb->do_something }
 
 my $e;
 if ($e = Exception::Class->caught('Facebook::Graph::Exception::General')) {
    warn $e->error;
    exit;
 }

=head2 Facebook::Graph::Exception::RPC

An exception that is thrown communicating with Facebook. It has several extra methods.

 eval { $fb->do_something }
 
 my $e;
 if ($e = Exception::Class->caught('Facebook::Graph::Exception::RPC')) {
    warn $e->error;
    warn $e->http_code;
    warn $e->http_message;
    warn $e->facebook_message;
    warn $e->facebook_type;
    warn $e->uri
    exit;
 }

=head3 http_code

The HTTP status code can be used to help figure out what went wrong: Example: C<401>.

=head3 http_message

The HTTP status message usually isn't all that useful, but in case you need it, here it is. Example: C<Authorization Required>.

=head3 facebook_message

Facebook will return an error message to help you diagnose what is wrong with your request, which can sometimes be useful. Example: C<Error validating application.>

=head3 facebook_type

Facebook returns various exception types that can sometimes be helpful in diagnosing problems. Example: C<OAuthException>.

=head3 uri

The URI used to request information from Facebook. In the case of a GET this can be very useful. Not so useful on a POST.


=head1 LEGAL

Facebook::Graph is Copyright 2010 Plain Black Corporation (L<http://www.plainblack.com>) and is licensed under the same terms as Perl itself.

=cut

