package Array::Lock;
require 5.007003;
# use strict;
# use warnings;
require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(lock_values unlock_values lock_keys 
  unlock_keys lock_array unlock_array) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our $VERSION = '0.01';

=head1 NAME

Array::Lock- Subroutines to make Arrays read-only.

=head1 SYNOPSIS

  use Hash::Util qw(lock_keys   unlock_keys
                    lock_value  unlock_value
                    lock_array  unlock_array);

  @array  = qw/f o o b a r/;
  @keyset = qw/1 2 4/;
  lock_values(@array);
  lock_values(@array, @keyset);
  unlock_values(@array);

  lock_keys   (@array);
  unlock_keys (@array);

  lock_array   (@array);
  unlock_array (@array);

=head1 DESCRIPTION

C<Array::Lock> contains functions to lock an array.

By default C<Array::Lock> does not export anything.

=head2 Restricted hashes

Perl 5.8.0 (inadvertantly for arrays?) introduces the ability to restrict
an array to a range of indexes... No indexes outside of these can be
altered..  It also introduces the ability to lock an individual index so
it cannot be deleted and the value cannot be changed.

=over 4

=item lock_keys

=item unlock_keys

  lock_keys(@array);

Restricts the given arrays indexes to its current amount. No more indexes
can be added; however, the values of current indexes can be changed.
exists() will still work, but delete() will not, as its standard behavior
is to get rid of the current index. B<Note>: the current implementation prevents
bless()ing while locked. Any attempt to do so will raise an exception. Of course
you can still bless() the array before you call lock_keys() so this shouldn't be
a problem.

Right now, lock_keys does not function with a range.  However, if I get feedback that
sugests that a range is desired, a hack of some sort may be possible.

  unlock_keys(%hash);

Removes the restriction on the array's indexes.

=cut
sub lock_keys   (\@) { Internals::SvREADONLY @{$_[0]}, 1; }
sub unlock_keys (\@) { Internals::SvREADONLY @{$_[0]}, 0; }
# You cannot lock a specific key, because of shift...
# I guess, you could lock that one key, and allow all the other
# keys _above_ it to be usable... should I do that?

=item lock_value

=item unlock_value

  lock_values   (@array, @keys);
  lock_values   (@array);
  unlock_values (@array, @keys);

Locks and unlocks index value pairs in an array.  If no set of keys is
specified, then all current keys are locked.

=cut

sub lock_values (\@;@) {
  my($array,@indexes) = @_;
  Internals::SvREADONLY $array->[$_], 1 for @indexes ? @indexes : $[.. $#{$array};
}

sub unlock_values (\@;@) {
  my($array,@indexes) = @_;
  Internals::SvREADONLY $array->[$_], 0 for @indexes ? @indexes : $[.. $#{$array};
}

=item B<lock_hash>

=item B<unlock_hash>

    lock_array(@array);

lock_array() locks an entire array, making all indexes and values readonly.
No value can be changed, no indexes can be added or deleted.

    unlock_array(@array);

unlock_arrray() does the opposite of lock_array().  All keys and values
are made read/write.  All values can be changed and keys can be added
and deleted.

=cut

sub lock_array (\@) { #You can only retrieve from the array
  my $array = shift;
  lock_keys(@$array);
  lock_values(@$array);
}

sub unlock_array (\@) {
  my $array = shift;
  unlock_keys(@$array);
  unlock_values(@$array);
}
1;
__END__

=back
=head1 SEE ALSO

L<Hash::Util>, L<ReadOnly>

=head1 AUTHOR

Gyan Kapur, E<lt>gkapur@cpan.org<gt>

This is really just Schwern's code, although he doesn't know it...

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gyan Kapur

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
