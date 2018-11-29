###############################################################################
# Package    : QueryProcess
# Description: Contains functions to process a Query
package QueryProcess;

use strict;
use warnings;

use Connection;

###############################################################################
# Function   : process - performs initial processing of a query, like
#                        establishing a connection, parsing output, and 
#                        generating additional requests if necessary 
# Parameters : query object, worklog, progress bar
# Returns    : none
sub process {
	my ($self,$query_obj,$worklog,$progress,$database) = @_;		
	
	# (A) Get specific query attributes
	if(defined $progress) { $self->increment_progressbar($progress); } # 10%
	my $searchengine_name = $query_obj->searchengine;	
	my $query = $query_obj->query;
	my $target = $query_obj->target;
	my $depth = $query_obj->depth;
	my $name = $query_obj->name;
	if($database->preferences_depth < $depth) { $depth = $database->preferences_depth; }
	
	# (B) Get searchengine matchstrings
	if(defined $progress) { $self->increment_progressbar($progress); } # 20%
	my $matchstring = $query_obj->matchstring;
	my $results_matchstring = $query_obj->results_matchstring;
	my $next_matchstring = $query_obj->next_matchstring;	
	my $cache_matchstring = $query_obj->cache_matchstring;	
	my $server = $query_obj->server;
	
	# (C) Get search preferences
	if(defined $progress) { $self->increment_progressbar($progress); } # 30%
	my $useragent = $database->preferences_useragent;
	my $proxy = $database->preferences_proxy;                   
                        
	# (D) Establish a connection and get output         
	if(defined $progress) { $self->increment_progressbar($progress); } # 40%
	$worklog->insert_msg("Requesting $name from $searchengine_name for target $target\n");
	my $ref_lines = Connection->send_request($server, $query, $useragent, $proxy, $worklog);
	if($ref_lines) {
	
   	# (E) Process output
	   if(defined $progress) { $self->increment_progressbar($progress); } # 50%
	   my ($next_query, $totalhits);
	   my $results = $query_obj->results;
	   my $cached = $query_obj->cached;
	   
	   foreach my $line (@$ref_lines) {
		if (!(defined $totalhits) && ($line =~ /$matchstring/)) {
			$totalhits = $1;
			$totalhits =~ s/,//g;
				$worklog->insert_msg("Request $name from $searchengine_name returned $totalhits hits for target $target\n",'info');
		}

		if ($depth > 0 && $line =~ /$next_matchstring/) {
		#TODO: Next query must go through common cleaning function
			$next_query = $1;				   		
			$next_query =~ s/\&amp\;/\&/g; #substitute ampersand		
			$next_query =~ s/\s/\+/g; #substitute ampersand				
		}
		
		if($totalhits && (my @array = ($line =~ /$results_matchstring/g))) {
			foreach my $result (@array) {
			   # be careful with this one, designed to avoid advertising sites
			   #if($result =~ /^http:\/\//) { push @$results, $result; }
			   push @$results, $result;
			 }
		}
		
		# TODO: SEAT's caching mechanism needs more work	    	
		#if(my @array = ($line =~ /$cache_matchstring/g)) {
		#   foreach my $cache (@array) {
		#      push @$cached, $cache;
		#   }
		#}
	   }
	   # AOL SUX !!!
	   if($searchengine_name eq "AOL" && $next_query) { $next_query = "/aol/".$next_query }
	   if($searchengine_name eq "DMOZ" && $next_query) { $next_query = "/cgi-bin/".$next_query }
	   
	   # (F) Save results
	   if(defined $progress) { $self->increment_progressbar($progress); } # 60%
	   $query_obj->totalhits($totalhits);
	   $query_obj->results($results);
	   $query_obj->cached($cached);
	   	   
	   # (G) Check if more runs are required
	   if(defined $progress) { $self->increment_progressbar($progress); } # 70%
	   if($depth && $next_query) {
		$depth--;
		$query_obj->depth($depth);
		$query_obj->query($next_query);
		Worker->do_job('depth', $query_obj);
	   } else {
		$query_obj->finished(1);
	   }  
   } else {
   	Worker->do_job('depth', $query_obj);
   }
   
   # (H) Check if we are finished and quit
   if(defined $progress) { $self->increment_progressbar($progress); } # 80%
   if($query_obj->finished) {
   	$self->process_results($query_obj);
      Worker->done_job('done',$query_obj);
      
      # (J) Reuse mined results      
	   if(defined $progress) { $self->increment_progressbar($progress); } # 90%
      my $use_mined = $query_obj->use_mined; 
      if($use_mined == 2) {$self->process_mined($query_obj, $database); }
      
   # If you fail once, try and try again ;)
   }
   
   if(defined $progress) { $self->increment_progressbar($progress,1); } # 100%
   sleep $database->preferences_sleep();
}

###############################################################################
# Function   : process_results - final processing of a query.
# Parameters : query object
# Returns    : none
sub process_results {
      my ($self, $query_obj) = @_;

      my $results = $query_obj->results;
      my $target = $query_obj->target;
         
   	# If target was not specified match all domains
	   if ($target =~ /(\d+).(\d+).(\d+).(\d+)/) {
	      $target = "_GLOBAL";
	   }
	      
	   # Check if new domain is discovered
	   my %mined;
	   foreach (@$results) {
	   	if ($target && /:\/\/([\.\w]+)[\:\/]/) {
	   		my $mined=$1;
	   		if ($target eq "_GLOBAL" || $mined =~/$target/) {
	   			$mined{$mined} = undef;
	   		}
	   	}
	   }
      my @array = sort keys %mined;
      $query_obj->mined(\@array);
}  

###############################################################################
# Function   : process_mined - generate new queries for each mined result
# Parameters : query object
# Returns    : none
sub process_mined {
   my($self, $query_obj, $database) = @_;
   
   my $mined_array = $query_obj->mined;
   my $target = $query_obj->target;
   my $oldquery = $query_obj->query;
   
   foreach my $mined (@$mined_array) {
	   my $depth = $database->preferences_depth;
   	my $query = $oldquery;	  
   		  
	   # prepare the new mined query object
	   $query =~ s/$target/$mined/;
   		      
	   # HACK WARNING: some architectural changes needed
      # to allow for external object generation
      # special case when we are scanning ip
      if($query =~ "ip%3A") {
         my $searchengine = $database->searchengine($query_obj->searchengine);
         my $site = $$searchengine{site};
         $query =~ s/ip%3A/$site/;
         $query =~ s/\s/\+/g ;     #changing spaces to + signs
         $query =~ s/\++/\+/g;     #remove double spaces   
	 $query =~ s/\&amp\;/\&/g; #substitute ampersand  
      }   	
            
      $query_obj->query($query);
      $query_obj->target($mined);
      $query_obj->depth($depth);
      $query_obj->mined(undef);
      $query_obj->results(undef);
      $query_obj->use_mined(0);
      Worker->do_job('mined',$query_obj);
   }
}


###############################################################################
# Function   : increment_progressbar - updates progress bar
# Parameters : progress bar, fraction
# Returns    : none
sub increment_progressbar() {
	my ($self,$progress,$fraction) = @_;

   unless(defined $fraction) {
	   $fraction = $progress->get_fraction;
	   if($fraction == 1) { $fraction = 0 }	
	   $fraction += .10;
   }
   
	Gtk2::Gdk::Threads->enter;
	$progress->set_fraction ($fraction);
	$progress->set_text ($fraction * 100 .'%');
	Gtk2::Gdk::Threads->leave;
}
   
1;
