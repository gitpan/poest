# $Id: Plugin.pm,v 1.1 2003/03/12 20:42:39 cwest Exp $
package POEST::Plugin;

use strict;
$^W = 1;

use vars qw[$VERSION];
$VERSION = (qw$Revision: 1.1 $)[1];

use POE qw[Component::Server::SMTP];

sub CONFIG () { [ ] }

sub new {
  my ($class, %args) = @_;

  return bless \%args, $class;
}

1;

__END__

=pod

=head1 NAME

POEST::Plugin - Details of, and Base Class for Writing a POEST Plugin

=head1 ABSTRACT

Details for writing a POEST Plugin.  The interface and prescribed
conventions are detailed.

=head1 DESCRIPTION

poest plugins are classes.  With the exception of the C<EVENT()>, and
C<new()> methods listed later in this document, all other methods will
be posted from the POE kernel.  You'll need to read some documentation
on POE if you don't know what I'm talking about.

=head2 Conventions

=head3 Plugin naming and purpose

The plugin heirarchy has some naming conventions.  It is highly
recommended that you follow them.  If you find yourself doing something
new and unique, it is imperitive you contact the author of poest, Casey
West, and let him know what you're doing.  There is a good chance it's
really cool and you should share, plus, he can help with naming.

The following rules apply.

B<NOTE>: The following is still fuzzy.  A clear definition of rules of
interaction must be created!

=over 4

=item POEST::Plugin::Accept

Plugins that accept incomming email.  These plugins will usually handle
at least the C<MAIL>, C<RCPT>, C<DATA>, and C<gotDATA> events.  They
should take in the message data and create a
L<Mail::Internet|Mail::Internet> object from it.  Next, that object must
be handed off to the Queue.

=item POEST::Plugin::Queue

Plugins in this space handle message queues.  There is no set way for
a queue to handle it's messages, just so long as it tries to get them
out the door.  By out the door, I mean that at some point messages
should be passed to delivery agents.

=item POEST::Plugin::Deliver

These plugins deliver the mail.  Novel, I know.  There is no set place
these messages should be delivered to, so have a blast.

=item POEST::Plugin::Check

Plugins under this category do a lot of checking conditions to see
if everything adds up.  They're mostly used to determine if everything
is OK.  When things don't go well, these plugins will intercept the
calling stack and return an error or something.

=item POEST::Plugin::General

General commands should go here.  This includes things such as
C<send_banner>, C<HELO>, and so on.

=item POEST::Plugin::Feature

These plugins implement special features that don't really have to do
with the straigt forward process of delivering mail.

=back

=head3 Base class POEST::Plugin

This class can be used as a base class for other plugins.  Granted, if
you're sub-classing some higher-level plugin, you know that you're
sub-classing POEST::Plugin behind the scenes.

Sub-classing is simple.

  package POEST::Plugin::Queue::mysql;
  use base qw[POEST::Plugin];

=head2 Required Methods

=head3 EVENTS()

This method returns the events that the plugin will handle.  The most
simple thing to return is a list reference contianing the names of
the events.  each named event will corrispond directly to the name
of a method in the plugin.  The other format is to return a hash
reference with the name of events as keys and the method names in the
plugin as the values.

There are several ways to define this method.  The most cost effective
is an inline sub.

  sub EVENTS () { [ qw[MAIL RCPT DATA gotDATA] ] }

Another way is using the L<constant|constant> pragma.

  use constant EVENTS => {
    MAIL    => 'smtp_mail',
    RCPT    => 'smtp_rcpt',
    DATA    => 'smtp_data',
    gotDATA => 'smtp_got_data',
  };

Both forms are valid, though the first form will be used as much as
possible in the official distributions.

The plugin will not be given any events to handle except the ones it
specifies.  Event names are case senstive.

A plugin should document all the events it plans to handle, as well
as any special cases that may arise in unforseen flow of execution.
In other words, anything clever must be documented.

B<NOTE>: There should be a good way of specifying that 'all' events
should be handled.

=head3 CONFIG()

This method returns the configuration parameters required by the plugin.
Each parameter you want must be listed, it will be returned as a list
reference.  By default, this base class provides a C<CONFIG()> method that
returns an empty list, indicating that no configuration parameters are
needed.  Only the configuration parameters requested will be passed to
the plugin upon initialization using the C<new()> constructor.

Just as C<EVENTS()>, there are several options for declaring this method.
Inline subroutines or the use of the C<constant|constant> pragma are
acceptable.  Here is an example.

  sub CONFIG() { [ qw[hostname port aliases] ] }

A plugin should document all the configuration parameters it expects
to find.  The syntax for the value, and any outstanding issues, such
as external files, that must be taken into consideration.

B<NOTE>: There should be a good way of specifying that 'all'
configuration parameters are required.

=head3 new()

This is the constructor for the plugin.  Since all plugins are classes,
it's important to get an object instance.  In most cases, C<new()> will
be called when poest is started.  C<new()> will be passed a hash (key,
value pair) of configuration options and is expeted to return an object.

If your class doesn't supply C<new()>, and you're sub-classing as you
should, a generic C<new()> is provided for you by POEST::Plugin.  It
looks just like the example below.

Example.

  sub new {
    my ($self, %args) = @_;
    
    return bless \%args, $self;
  }

If you want to do the same thing as the example, with just a little
more functionality, save yourself some work with this fun trick.

  sub new {
    my $self = shift->SUPER::new( @_ );
    
    # .. do initialization ..
    
    return $self;
  }

C<new()> should check the validity of the configuration parameters
passed to it.  During copious and thourough validation, if something
is wrong the plugin should throw an exception.  This is a good thing,
as it will happen on server startup and may be logged and dealt with
appropriatley.

=head3 event_handlers()

Finally, the only other required methods are the ones corrisponding to
the events the plugin reports it can handle, via the C<EVENTS()> method.

Example.

  sub HELO {
    my ($kernel, $heap, $self, $session, @args) =
      @_[KERNEL, HEAP, OBJECT, SESSION, ARG0 .. $#_];
    
    my $client = $heap->{client};
    $client->put( SMTP_OK, "Welcome." );
  }

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>

=head1 COPYRIGHT

Copyright (c) 2003 Casey West.  All rights reserved.  This program is
free software; you may redistribute it and/or modify it under the same
terms as Perl itself.

=head1 SEE ALSO

L<perl>, L<POEST::Server>, L<POE>, L<POE::Session::MultiDispatch>,
L<POE::Component::Server::SMTP>, L<POE::Session>, L<POE::Kernel>.

http://poe.perl.org

=cut
