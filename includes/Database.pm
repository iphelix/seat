###############################################################################
# Package    : Database
# Description: The heart and soul of SEAT. Database handles storage and 
#              retrieval of data structures during all three stages
package Database;

use strict;
use warnings;

use Analysis;

use threads::shared;

###############################################################################
# Values below are shared among threads
our $_depth : shared     = 0;     # default search depth
our $_use_mined : shared = 0;     # default use shared results
our $_sleep : shared     = 2;     # default sleep time between runs
our $_nthreads : shared  = 15;    # default max number of active workers/threads
our $_useragent : shared = 'SEAT'; # default user agent
our $_proxy : shared     = undef; # default proxy server

###############################################################################
# Function   : new - instantiates a new Database object
# Parameters : none
# Returns    : Database object
sub new {
	my $class = shift;
	my $self = {
	   TARGETS        => undef,
	   QUERIES        => undef,	
	   SEARCHENGINES  => undef,
	   RESULTS        => undef,
	};
	bless ($self, $class);
	return $self;
}
###############################################################################
# Preferences Functions

sub preferences_depth {
   my $self = shift;
   if(@_) { $_depth = shift; }
   return $_depth;
}

sub preferences_mined {
   my $self = shift;
   if(@_) { $_use_mined = shift; }
   return $_use_mined;
}

sub preferences_sleep {
   my $self = shift;
   if(@_) { $_sleep = shift; }
   return $_sleep;
}

sub preferences_threads {
   my $self = shift;
   if(@_) { $_nthreads = shift; }
   return $_nthreads;
}

sub preferences_useragent {
   my $self = shift;
   if(@_) { $_useragent = shift; }
   return $_useragent;
}

sub preferences_proxy {
   my $self = shift;
   if(@_) { $_proxy = shift; }
   return $_proxy;
}

###############################################################################
# Targets Functions

sub targets {
   my $self = shift;
	if(@_) { $self->{TARGETS} = shift }
	return $self->{TARGETS};
}

sub target {
   my ($self, $name, $active) = @_;
   
   if (defined $active) { $self->{TARGETS}->{$name} = $active; }
   
   return $self->{TARGETS}->{$name};
}

sub target_exists {
   my ($self, $name) = @_;
   if($name && $self->{TARGETS}->{$name}) { return 1 }
   else { return 0 }
}

sub target_remove {
   my ($self, $name) = @_;
   if($name) { delete($self->{TARGETS}->{$name}) }
}

sub target_purge {
   my $self = shift;
   $self->{TARGETS} = ();
}

sub print_targets {
   my $self = shift;
   print "====== T A R G E T S ======\n";
   print Dumper($self->{TARGETS});
}

###############################################################################
# Queries Functions

sub queries {
   my $self = shift;
	if(@_) { $self->{QUERIES} = shift }
	return $self->{QUERIES};
}

sub query {
   my ($self, $name, $active, $description) = @_;
   
   if (defined $active) { $self->{QUERIES}->{$name}[0] = $active; }
   if (defined $description ) { $self->{QUERIES}->{$name}[1] = $description; }
   
   return $self->{QUERIES}->{$name};
}

sub query_exists {
   my ($self, $name) = @_;
   if($name && $self->{QUERIES}->{$name}) { return 1 }
   else { return 0 }
}

sub query_remove {
   my ($self, $name) = @_;
   if($name) { delete($self->{QUERIES}->{$name}) }
}

sub query_purge {
   my $self = shift;
   $self->{QUERIES} = ();
}


sub print_queries {
   my $self = shift;
   print "====== Q U E R I E S ======\n";
   print Dumper(\$self->{QUERIES});
}

###############################################################################
# Search Engines Functions

sub searchengines {
   my $self = shift;
	if(@_) { 
	   my %searchengines = @_;
	   $self->{SEARCHENGINES} = \%searchengines; }
	return $self->{SEARCHENGINES};
}

sub searchengines_list {
   my $self = shift;
   my $searchengines = $self->{SEARCHENGINES};
   return keys %$searchengines;
}

sub searchengine {
   my ($self, $name, $active, $prefix, $server, $matchstring, $results_matchstring, $next_matchstring, $cache_matchstring, $site, $ip, $intitle, $inurl, $filetype) = @_;
   if($name) {
      if(defined $active)              { $self->{SEARCHENGINES}->{$name}->{active}              = $active; }
      if(defined $prefix)              { $self->{SEARCHENGINES}->{$name}->{prefix}              = $prefix; }
      if(defined $server)              { $self->{SEARCHENGINES}->{$name}->{server}              = $server; }
      if(defined $matchstring)         { $self->{SEARCHENGINES}->{$name}->{matchstring}         = $matchstring; }
      if(defined $results_matchstring) { $self->{SEARCHENGINES}->{$name}->{results_matchstring} = $results_matchstring; }
      if(defined $next_matchstring)    { $self->{SEARCHENGINES}->{$name}->{next_matchstring}    = $next_matchstring; }
      if(defined $cache_matchstring)   { $self->{SEARCHENGINES}->{$name}->{cache_matchstring}   = $cache_matchstring; }
      if(defined $site)                { $self->{SEARCHENGINES}->{$name}->{site}                = $site; }
      if(defined $ip)                  { $self->{SEARCHENGINES}->{$name}->{ip}                  = $ip; }
      if(defined $intitle)             { $self->{SEARCHENGINES}->{$name}->{intitle}             = $intitle; }
      if(defined $inurl)               { $self->{SEARCHENGINES}->{$name}->{inurl}               = $inurl; }
      if(defined $filetype)            { $self->{SEARCHENGINES}->{$name}->{filetype}            = $filetype; }
   }
   return $self->{SEARCHENGINES}->{$name};  
}

sub searchengine_exists {
   my ($self, $name) = @_;
   if($name && $self->{SEARCHENGINES}->{$name}) { return 1 }
   else { return 0 }   
}

sub searchengine_remove {
   my ($self, $name) = @_;
   if($name) { delete($self->{SEARCHENGINES}->{$name}) }
}

sub searchengine_purge {
   my $self = shift;
   $self->{SEARCHENGINES} = ();
}

sub print_searchengines {
   my $self = shift;
   print "====== SEARCH ENGINES ======\n";
   print Dumper($self->{SEARCHENGINES});
}

###############################################################################
# Results Functions

sub results {
   my $self = shift;
	if(@_) { $self->{RESULTS} = shift }
	return $self->{RESULTS};
}

sub result {
   my ($self,$target,$name,$searchengine,$totalhits,$mined,$results) = @_;

   $self->{RESULTS}->{$target}->{$name}->{$searchengine} = {
         TOTALHITS => $totalhits,
         MINED => $mined,
         RESULTS => $results,  
   };          
}

sub get_result {
   my ($self,$target,$query,$searchengine) = @_;
   if(defined $target && $query && $searchengine) {
      return $self->{RESULTS}->{$target}->{$query}->{$searchengine};
   }
   elsif(defined $target && $query) {
      my $searchengines =  $self->{RESULTS}->{$target}->{$query};
      return (keys %$searchengines);
   }
   elsif(defined $target) {
      my $queries = $self->{RESULTS}->{$target};
      return (keys %$queries);
   }
   else {
      my $targets = $self->{RESULTS};
      return (keys %$targets);
   }
 }

sub results_purge {
   my $self = shift;
   $self->{RESULTS} = ();
}

sub results_remove_target {
   my ($self, $target) = @_;
   if($target) { delete($self->{RESULTS}->{$target}) }
}

sub print_results {
   my $self = shift;
   print "====== R E S U L T S ======\n";
   print Dumper(\$self->{RESULTS});
}

1;
