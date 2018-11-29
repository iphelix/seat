package Thread::Queue::Any;

# Make sure we inherit from Thread::Queue
# Make sure we have version info for this module
# Make sure we do everything by the book from now on

@ISA = qw(Thread::Queue);
$VERSION = '0.07';
use strict;

# Make sure we have Storable
# Make sure we have queues

use Storable ();      # no need to pollute namespace
use Thread::Queue (); # no need to pollute namespace

# Allow for synonym for dequeue_dontwait

*dequeue_nb = \&dequeue_dontwait;

# Satisfy -require-

1;

#---------------------------------------------------------------------------
#  IN: 1 instantiated object
#      2..N parameters to be passed as a set onto the queue

sub enqueue {
    shift->SUPER::enqueue( Storable::freeze( \@_ ) );
}

#---------------------------------------------------------------------------
#  IN: 1 instantiated object
# OUT: 1..N parameters returned from a set on the queue

sub dequeue {
    @{Storable::thaw( shift->SUPER::dequeue )};
}

#---------------------------------------------------------------------------
#  IN: 1 instantiated object
# OUT: 1..N parameters returned from a set on the queue

sub dequeue_dontwait {
    return unless my $ref = shift->SUPER::dequeue_nb;
    @{Storable::thaw( $ref )};
}

#---------------------------------------------------------------------------
#  IN: 1 instantiated object
# OUT: 1..N parameters returned from a set on the queue

sub dequeue_keep {
#    return unless my $ref = shift->SUPER::dequeue_keep; # doesn't exist yet
    return unless my $ref = shift->[0];			# temporary
    @{Storable::thaw( $ref )};
}

#---------------------------------------------------------------------------

__END__

=head1 NAME

Thread::Queue::Any - thread-safe queues for any data-structure

=head1 SYNOPSIS

    use Thread::Queue::Any;
    my $q = Thread::Queue::Any->new;
    $q->enqueue("foo", ["bar"], {"zoo"});
    my ($foo,$bar,$zoo) = $q->dequeue;
    my ($foo,$bar,$zoo) = $q->dequeue_dontwait;
    my ($iffoo,$ifbar,$ifzoo) = $q->dequeue_keep;
    my $left = $q->pending;

=head1 DESCRIPTION

                    *** A note of CAUTION ***

 This module only functions on Perl versions 5.8.0-RC3 and later.
 And then only when threads are enabled with -Dusethreads.  It is
 of no use with any version of Perl before 5.8.0-RC3 or without
 threads enabled.

                    *************************

A queue, as implemented by C<Thread::Queue::Any> is a thread-safe 
data structure that inherits from C<Thread::Queue>.  But unlike the
standard C<Thread::Queue>, you can pass (a reference to) any data
structure to the queue.

Apart from the fact that the parameters to C<enqueue> are considered to be
a set that needs to be enqueued together and that C<dequeue> returns all of
the parameters that were enqueued together, this module is a drop-in
replacement for C<Thread::Queue> in every other aspect.

Any number of threads can safely add elements to the end of the list, or
remove elements from the head of the list. (Queues don't permit adding or
removing elements from the middle of the list).

=head1 CLASS METHODS

=head2 new

 $queue = Thread::Queue::Any->new;

The C<new> function creates a new empty queue.

=head1 OBJECT METHODS

=head2 enqueue LIST

 $queue->enqueue( 'string',$scalar,[],{} );

The C<enqueue> method adds a reference to all the specified parameters on to
the end of the queue.  The queue will grow as needed.

=head2 dequeue

 ($string,$scalar,$listref,$hashref) = $queue->dequeue;

The C<dequeue> method removes a reference from the head of the queue,
dereferences it and returns the resulting values.  If the queue is currently
empty, C<dequeue> will block the thread until another thread C<enqueue>s.

=head2 dequeue_dontwait

 ($string,$scalar,$listref,$hashref) = $queue->dequeue_dontwait;

The C<dequeue_dontwait> method, like the C<dequeue> method, removes a
reference from the head of the queue, dereferences it and returns the
resulting values.  Unlike C<dequeue>, though, C<dequeue_dontwait> won't wait
if the queue is empty, instead returning an empty list if the queue is empty.

For compatibility with L<Thread::Queue>, the name "dequeue_nb" is available
as a synonym for this method.

=head2 dequeue_keep

 ($string,$scalar,$listref,$hashref) = $queue->dequeue_keep;

The C<dequeue_keep> method, like the C<dequeue_dontwait> method, takes a
reference from the head of the queue, dereferences it and returns the
resulting values.  Unlike C<dequeue_dontwait>, though, the C<dequeue_keep>
B<won't remove> the set from the queue.  It can therefore be used to test if
the next set to be returned from the queue with C<dequeue> or
C<dequeue_dontwait> will have a specific value.

=head2 pending

 $pending = $queue->pending;

The C<pending> method returns the number of items still in the queue.

=head1 REQUIRED MODULES

 Storable (any)
 Thread::Queue (any)

=head1 CAVEATS

Passing unshared values between threads is accomplished by serializing the
specified values using C<Storable> when enqueuing and de-serializing the queued
value on dequeuing.  This allows for great flexibility at the expense of more
CPU usage.  It also limits what can be passed, as e.g. code references can
B<not> be serialized and therefore not be passed.

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2002-2003 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<threads>, L<threads::shared>, L<Thread::Queue>, L<Storable>.

=cut
