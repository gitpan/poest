# $Id: General.pm,v 1.1 2003/03/12 20:42:39 cwest Exp $
package POEST::Plugin::General;

=pod

=head1 NAME

POEST::Plugin::General - General SMTP commands implemented.

=head1 ABSTRACT

This class implements general SMTP commands, in order to get them
out of the way.

=head1 DESCRIPTION

There are some SMTP commands that are fairly straight forward
to implement, they are implemented here.

=cut

use strict;
$^W = 1;

use vars qw[$VERSION];
$VERSION = (qw$Revision: 1.1 $)[1];

use base qw[POEST::Plugin];
use POE qw[Component::Server::SMTP];

=head2 Events

=head3 HELO

Returns the response for C<HELO>.

=head3 QUIT

Returns the response for C<QUIT>.

=head3 send_banner

Sends the banner for the SMTP server when a session initializes.  This
is how an SMTP server introduces itself to the client.

=cut

sub EVENTS () { [ qw[ HELO  QUIT send_banner ] ] }

=head2 Configuration

=head3 hostname

The hostname that we run as a primary.  This is used when sending the
banner.

=cut

sub CONFIG () { [ qw[ hostname ] ] }

sub send_banner {
	my ($kernel, $self, $heap) = @_[KERNEL, OBJECT, HEAP];
	my $client = $heap->{client};

	my $banner = "$self->{hostname} ESMTP poest/v0.1";

	$client->put( SMTP_SERVICE_READY, $banner );
}

sub HELO {
	my ($kernel, $self, $heap, $host) = @_[KERNEL, OBJECT, HEAP, ARG0];
	my $client = $heap->{client};

	$client->put( SMTP_OK, qq[$self->{hostname} Would you like to play a game?] );
}

sub QUIT {
	my ($kernel, $heap) = @_[KERNEL, HEAP];
	my $client = $heap->{client};

	$client->put( SMTP_QUIT, q[How about a nice game of chess?] );
	$heap->{shutdown_now} = 1;
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
