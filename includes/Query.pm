###############################################################################
# Package    : QueryProcess
# Description: Stores primitives necessary to generate a complete search query, 
#              as well as store processed results for this query
package Query;
use strict;

use QueryProcess;

###############################################################################
# Function   : new - instantiates a new Query object
# Parameters : target, searchengine name, query, database object
# Returns    : Query object
sub new {
	my ($class,$target,$searchengine,$query) = @_;

	my $self = {
		TARGET              => $target,
		SEARCHENGINE        => $searchengine,
	   NAME                => $query,
	   MATCHSTRING         => undef,       
	   NEXT_MATCHSTRING    => undef,
	   RESULTS_MATCHSTRING => undef,
	   CACHE_MATCHSTRING   => undef,
	   SERVER              => undef,
		QUERY               => undef,
		TOTALHITS           => undef,
		RESULTS		        => undef,
		MINED		           => undef,
		CACHED              => undef,
		DEPTH               => undef,
		USEMINED            => undef,
		FINISHED	           => undef,
	};
	bless ($self, $class);
	return $self;
}

sub matchstring {
   my $self = shift;
   if (@_) { $self->{MATCHSTRING} = shift }
   return $self->{MATCHSTRING};
}

sub next_matchstring {
   my $self = shift;
   if (@_) { $self->{NEXT_MATCHSTRING} = shift }
   return $self->{NEXT_MATCHSTRING};
}

sub results_matchstring {
   my $self = shift;
   if (@_) { $self->{RESULTS_MATCHSTRING} = shift }
   return $self->{RESULTS_MATCHSTRING};
}

sub cache_matchstring {
   my $self = shift;
   if (@_) { $self->{CACHE_MATCHSTRING} = shift }
   return $self->{CACHE_MATCHSTRING};
}

sub server {
	my $self = shift;
	if (@_) { $self->{SERVER} = shift }
	return $self->{SERVER};
}

sub name {
	my $self = shift;
	if (@_) { $self->{NAME} = shift }
	return $self->{NAME};
}

sub query {
	my $self = shift;
	if (@_) { $self->{QUERY} = shift }
	return $self->{QUERY};
}

sub searchengine {
	my $self = shift;
	if (@_) { $self->{SEARCHENGINE} = shift }
	return $self->{SEARCHENGINE};
}

sub target {
	my $self = shift;
	if(@_) { $self->{TARGET} = shift }
	return $self->{TARGET};
}

sub totalhits {
	my $self = shift;
	if(@_) { $self->{TOTALHITS} = shift }
	return $self->{TOTALHITS};
}

sub results {
	my $self = shift;
	if(@_) { $self->{RESULTS} = shift }
	return $self->{RESULTS};
}

sub mined {
	my $self = shift;
	if(@_) { $self->{MINED} = shift }
	return $self->{MINED};
}

sub cached {
	my $self = shift;
	if(@_) { $self->{CACHED} = shift }
	return $self->{CACHED};
}

sub depth {
   my $self = shift;
   if(@_) { $self->{DEPTH} = shift }
   return $self->{DEPTH};
}

sub use_mined {
   my $self = shift;
   if(@_) { $self->{USEMINED} = shift }
   return $self->{USEMINED};
}

sub finished {
	my $self = shift;
	if(@_) { $self->{FINISHED} = shift }
	return $self->{FINISHED};
}

sub process {
   my $self = shift;
   QueryProcess->process($self, @_);
}

1;
