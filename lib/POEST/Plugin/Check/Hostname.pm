# $Id: Hostname.pm,v 1.1 2003/03/12 20:42:39 cwest Exp $
package POEST::Plugin::Check::Hostname;

=pod

=head1 NAME

POEST::Plugin::Check::Hostname - Check for a proper host in HELO.

=head1 ABSTRACT

Check for a proper host in the HELO command sent from the client.

=head1 DESCRIPTION

=cut

use strict;
$^W = 1;

use vars qw[$VERSION];
$VERSION = (qw$Revision: 1.1 $)[1];

use base qw[POEST::Plugin];
use POE qw[Component::Server::SMTP];

=head2 Events

=head3 HELO

Intercept the HELO event.  If configured to require a hostname in the
HELO sent by the client, it will check the acceptible hosts list for
the host specified.  If said host is in the list, execution will
continue on to the standard HELO implementation that greets the client.
If it fails, an error will be sent to the client.

=cut

sub EVENTS () { [ qw[ HELO ] ] }

=head2 Configuration

=head3 requirehost

If true, a specified (and correct) host will be required.  Otherwise
these checks will be bypassed.  Kind of useless without this, isn't
it?

=head3 allowedhost

This option has multiple values.  A list of hosts that are allowed for
this SMTP server.

=cut

sub CONFIG () { [ qw[ requirehost allowedhost ] ] }

sub HELO {
	my ($kernel, $heap, $self, $session, $host) = @_[KERNEL, HEAP, OBJECT, SESSION, ARG0];
	my $client = $heap->{client};

	if ( $self->{requirehost} ) {
		my (@hosts) = ref $self->{allowedhost} ?
			@{ $self->{allowedhost} } : $self->{allowedhost};

		unless ( $host && grep { $host eq $_ } @hosts ) {
			$client->put( SMTP_ARG_SYNTAX_ERROR, qq[Syntax: HELO hostname] );
			$session->stop;
		}
	}
}

1;

__END__

=pod

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>

=head1 COPYRIGHT

Copyright (c) 2003 Casey West.  All rights reserved.  This program is
free software; you may redistribute it and/or modify it under the same
terms as Perl itself.

=head1 SEE ALSO

L<perl>, L<POEST::Server>, L<POEST::Plugin>.

=cut
