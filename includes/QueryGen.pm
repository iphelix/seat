###############################################################################
# Package    : QueryGen
# Description: Generates new Queries and applies Search Engine Abstraction 
package QueryGen;

use Query;

###############################################################################
# Function   : new - instantiate new query generator object
# Parameters : database
# Returns    : QueryGen object
sub new {
	my ($class,$database) = @_;

	my $self = {
         DATABASE => $database,
         STOP => 0,
	};
	bless ($self, $class);
	return $self;
}

###############################################################################
# Function   : process - generates Query objects, applies SE abstraction,
#                        and adds them to the Jobs Queue
# Parameters : worklog, database
# Returns    : QueryGen object
sub process {
   my ($self,$worklog,$progress) = @_;

   my $database = $self->{DATABASE};
   my $targets = $database->{TARGETS};
   my $queries = $database->{QUERIES};
   my $searchengines = $database->{SEARCHENGINES};
   
   my $count = 0;
      
   if(defined $progress) { $self->increment_progressbar($progress); }
   
   # If no queries were specified insert a blank one   
   unless(keys %$queries) { $$queries{_BLANK} = undef }

   foreach my $target (keys %$targets) {
      if($$targets{$target}) {                         
         foreach my $searchengine_name (keys %$searchengines) {
            if($$searchengines{$searchengine_name}->{active}) {
               foreach my $query (keys %$queries) {
		  if($$queries{$query}[0]) { 
			# sleep while Worker engine is paused
		  	while(Worker->status == 1) {
	                 sleep 1;
	                }
	                # quit if Worker engine stopped
                  	if(Worker->status == 2) {
                     		if(defined $progress) { $self->increment_progressbar($progress,1); }
                     		return;
                  	}   
                  
			if(defined $progress) { $self->increment_progressbar($progress); }
                  
	                my @job = ("$target", "$searchengine_name", "$query");     
        	        $query_obj = Query->new(@job);                  
                  
                	my $searchengine = $database->searchengine($query_obj->searchengine);
                 	my $prefix = $$searchengine{prefix};
	               	my $site = $$searchengine{site};
        	       	my $ip = $$searchengine{ip};
        	       	my $intitle = $$searchengine{intitle};
        	       	my $inurl = $$searchengine{inurl};
        	       	my $filetype = $$searchengine{filetype};
               	
        	       	$query_obj->matchstring($$searchengine{matchstring});
        	       	$query_obj->next_matchstring($$searchengine{next_matchstring});
        	       	$query_obj->results_matchstring($$searchengine{results_matchstring});
        	       	$query_obj->cache_matchstring($$searchengine{cache_matchstring});
        	       	$query_obj->server($$searchengine{server});
               
        	        my $depth = $database->preferences_depth;
        	        my $use_mined = $database->preferences_mined;
        	          
                	my $target = $query_obj->target;
                  
         	       if($query ne '_BLANK') {
                       	$query = $prefix.$query_obj->name;
                       } else {
                     	$query = $prefix;
                       }
                                    
                       # _GLOBAL is world code. Specifying this for a target will hack the planet,
                       # ban you from most search engines, and more than likely result in men
                       # in dark suites come knocking (or not ;)  ). You have been warned!
                       if ($target ne "_GLOBAL") {
                      	 # Check if the query is an ip address
                      	 if($target =~ /\d+\.\d+\.\d+\.\d+/) { $query .= " ip:$target"; }
                         else                                { $query .= " site:$target"; }
                       }
                      
                       # (A) Apply search engine abstraction
                       if($query_obj->searchengine ne "Google") {
                       	$query =~ s/[all]?site:/$site/;
                       	$query =~ s/ip:/$ip/;
               	       	$query =~ s/[all]?intitle:/$intitle/;
               	       	$query =~ s/[all]?inurl:/$inurl/;	
               	       	$query =~ s/[all]?intext://;
               	                  	
               	       	# filetype should come last
               	       	if($query =~ s/(ext:|filetype:)(.*?)\s//) {
               	       		$query .= $filetype.$2;
               	       	}               	                  	
               	       }
               	               		               	
               	       # (B) Clean up the query a bit
               	       $query =~ s/^\s+//;  #remove leading whitespaces
                       $query =~ s/\s+$//;  #remove trailing whitespaces
               
                       # (C) Make the query HTTP friendly
                       $query =~ s/\s/\+/g ;  #changing spaces to + signs
                       $query =~ s/\++/\+/g;  #remove double spaces
                       $query =~ s/\"/%22/g;  #changing quotes to %22
		       $query =~ s/\&amp\;/\&/g; #substitute ampersand
                       $query =~ s/\;/&/g;    #changing semicolons to &
                       $query =~ s/\:/%3A/g;  #changing colons to %3A
                  
                       $query_obj->query($query);
                       $query_obj->depth($depth);
                       $query_obj->use_mined($use_mined);
                                          
                       Worker->do_job($count, $query_obj);
                       $count++;
                  
                       # sleep between job generation not to overload the 
                       # host computer. The number of jobs between sleeps
                       # should be optimized.
                       unless($count % 100) { sleep 1 }
                       sleep 0.2;
		  }
               }
            }
         }
      }
   }
   if(defined $progress) { $self->increment_progressbar($progress,1); }
   $worklog->insert_msg("Finished generating $count jobs\n", "notice");
}

###############################################################################
# Function   : increment_progressbar - updates progress bar
# Parameters : progress bar, fraction
# Returns    : none
sub increment_progressbar() {
	my ($self,$progress,$fraction) = @_;

   unless(defined $fraction) {
	   $fraction = $progress->get_fraction;
	   if($fraction >= 1) { $fraction = 0 }	
	   $fraction += .10;
   }
   
	Gtk2::Gdk::Threads->enter;
	$progress->set_fraction ($fraction);
	$progress->set_text ('GNR');
	Gtk2::Gdk::Threads->leave;
}

1;
