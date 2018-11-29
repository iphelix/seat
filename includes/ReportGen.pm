###############################################################################
# Package    : ReportGen
# Description: Contains necessary functions to generate various reports
package ReportGen;

###############################################################################
# Function   : html - generates complete report in html 
# Parameters : filename,database
# Returns    : none
sub html {
   my ($self,$filename,$database) = @_;
   if (defined $filename && defined $database) { 
   
      open(SAV, ">$filename") || print ("Couldn't save to $filename");
      
      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
      my $timestamp = sprintf "%4d-%02d-%02d %02d:%02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min,$sec;
      
      my $output = "<html>\n";
      $output .= "<head>\n";
      $output .= "<title>SEAT Report $timestamp</title>\n";
           
      
      $output .= "<style type='text/css'>\n";      
      open (MYFILE, 'style.css');
      while (<MYFILE>) { $output .= $_; }
      close (MYFILE); 
      $output .= "</style>\n";
      
      $output .= "<script type='text/javascript'>\n";      
      open (MYFILE, 'listCollapse.js');
      while (<MYFILE>) { $output .= $_; }
      close (MYFILE); 
      $output .= "</script>\n";
      
      
      $output .= "<script type='text/javascript'>\n".
                 "window.onload = function () {\n".
                 "compactMenu('targets',false,'');\n".
                 "}".
                 "</script>\n";
      $output .= "</head>\n";
      $output .= "<body>\n";
      
      $output .= "<h1>SEAT Report $timestamp</h1>\n";
      
      $output .= "<ul id='targets'>\n";
      foreach my $target ($database->get_result) {
         $output .= "\t<li><h2>$target</h2>\n";
         $output .= "\t<ul>\n";
         foreach my $query ($database->get_result($target)) {
            $output .= "\t\t<li><h3>$query</h3>\n";
            $output .= "\t\t<ul>\n";
            
               my ($all_hits, $all_mined, $all_results);
            
            foreach my $searchengine ($database->get_result($target,$query)) {
               my $query_result = $database->get_result($target, $query, $searchengine);
               my $totalhits = $$query_result{TOTALHITS};
               my $mined = $$query_result{MINED};
               my $results = $$query_result{RESULTS};
               
               $all_hits += $totalhits;
               
               my $mined_column = "";
               foreach (@$mined) { $mined_column .= "<a href=\"http://$_\" target=\"_blank\">$_</a><br>\n"; }
               $all_mined .= "$mined_column";
               
               my $results_column;
               foreach (@$results) { $results_column .= "<a href=\"$_\" target=\"_blank\">$_</a><br>\n"; }
               $all_results .= "$results_column";
               
               if($mined_column && $results_column) {
                  $output .= "\t\t\t<li><b>$searchengine</b>\n";
                  $output .= "\t\t\t\t<ul>\n";
                  $output .= "\t\t\t<i>Total Hits: $totalhits</i>\n";
                  $output .= "\t\t\t<table valign='top'>\n";
                  $output .= "\t\t\t<tr><td>Mined</td><td>Results</td></tr>\n";
                  $output .= "\t\t\t<tr><td>$mined_column</td><td>$results_column</td></tr>\n";
                  $output .= "\t\t\t</table>\n";
                  $output .= "\t\t\t</ul>\n";
                  $output .= "\t\t\t</li>\n";               
               }
            }
               if($all_hits && $all_results) {
                  $output .= "\t\t\t<li><b>All</b>\n";
                  $output .= "\t\t\t\t<ul>\n";
                  $output .= "\t\t\t<i>Total Hits: $all_hits</i>\n";
                  $output .= "\t\t\t<table valign='top'>\n";
                  $output .= "\t\t\t<tr><td>Mined</td><td>Results</td></tr>\n";
                  $output .= "\t\t\t<tr><td>$all_mined</td><td>$all_results</td></tr>\n";
                  $output .= "\t\t\t</table>\n";
                  $output .= "\t\t\t</ul>\n";
                  $output .= "\t\t\t</li>\n";
               }         
            
            $output .= "\t\t</ul>\n";
            $output .= "\t\t</li>\n"
         }
         $output .= "\t</ul>\n";
         $output .= "\t</li>\n";
      }
      $output .= "</ul>\n";
      
      print SAV $output;
      close SAV;
   }
}

###############################################################################
# Function   : html_mined - generates just the mined pages report in html 
# Parameters : filename,database
# Returns    : none
sub html_mined {
   my ($self,$filename,$database) = @_;
   if (defined $filename && defined $database) { 
   
      open(SAV, ">$filename") || print ("Couldn't save to $filename");
      print "Saving to $filename\n";
      
      my $timestamp = time;
      
      my $output = "<html>\n";
      $output .= "<head>\n";
      $output .= "<title>SEAT Report $timestamp</title>\n";
      $output .= "<script type='text/javascript'>\n".
                 "window.onload = function () {\n".
                 "compactMenu('targets',false,'');\n".
                 "}".
                 "</script>\n";
      $output .= "</head>\n";
      $output .= "<body>\n";
      
      $output .= "<h1>SEAT Report $timestamp</h1>\n";
      
      $output .= "<ul id='targets'>\n";
      foreach my $target ($database->get_result) {
         $output .= "\t<li><h2>$target</h2>\n";
         $output .= "\t<ul>\n";
         
         my %mined_hash;
         foreach my $query ($database->get_result($target)) {            
               my ($all_hits, $all_mined, $all_results);
            
            foreach my $searchengine ($database->get_result($target,$query)) {
               my $query_result = $database->get_result($target, $query, $searchengine);
               my $mined = $$query_result{MINED};
               
               foreach (@$mined) { $mined_hash{$_} = undef; }               
            }
         }         
         foreach (sort keys %mined_hash) { $output .= "\t\t<li><a href=\"http://$_\" target=\"_blank\">$_</a></li>\n"; }
         
         $output .= "\t</ul>\n";
         $output .= "\t</li>\n";
      }
      $output .= "</ul>\n";
      
      print SAV $output;
      close SAV;
   }
}

###############################################################################
# Function   : html_results - generates just the page results report in html 
# Parameters : filename,database
# Returns    : none
sub html_results {   
   my ($self,$filename,$database) = @_;
   if (defined $filename && defined $database) { 
   
      open(SAV, ">$filename") || print ("Couldn't save to $filename");
      print "Saving to $filename\n";
      
      my $timestamp = time;
      
      my $output = "<html>\n";
      $output .= "<head>\n";
      $output .= "<title>SEAT Report $timestamp</title>\n";
      $output .= "<script type='text/javascript' src='listCollapse.js'></script>\n".
                 "<script type='text/javascript'>\n".
                 "window.onload = function () {\n".
                 "compactMenu('targets',false,'');\n".
                 "}".
                 "</script>\n";
      $output .= "</head>\n";
      $output .= "<body>\n";
      
      $output .= "<h1>SEAT Report $timestamp</h1>\n";
      
      $output .= "<ul id='targets'>\n";
      foreach my $target ($database->get_result) {
         $output .= "\t<li><h2>$target</h2>\n";
         $output .= "\t<ul>\n";
         
         my %results_hash;
         foreach my $query ($database->get_result($target)) {            
               my ($all_hits, $all_mined, $all_results);
            
            foreach my $searchengine ($database->get_result($target,$query)) {
               my $query_result = $database->get_result($target, $query, $searchengine);
               my $results = $$query_result{RESULTS};
               
               foreach (@$results) { $results_hash{$_} = undef; }               
            }       
         }
         
         foreach (sort keys %results_hash) { $output .= "\t\t<li><a href=\"$_\" target=\"_blank\">$_</a></li>\n"; }
         
         $output .= "\t</ul>\n";
         $output .= "\t</li>\n";
      }
      $output .= "</ul>\n";
      
      print SAV $output;
      close SAV;
   }

}

###############################################################################
# Function   : txt - generates complete report in txt
# Parameters : filename,database
# Returns    : none
sub txt {
   my ($self,$filename,$database) = @_;
   if (defined $filename && defined $database) { 
   
      open(SAV, ">$filename") || print ("Couldn't save to $filename");
      print "Saving to $filename\n";
      
      my $timestamp = time;
            
      my $output =  "SEAT Report $timestamp\n";
         $output .= "======================\n\n";
      
      foreach my $target ($database->get_result) {
         $output .= "+ $target\n";
         $output .= "|\n";
         foreach my $query ($database->get_result($target)) {
            $output .= "+---+ $query\n";
                        
            foreach my $searchengine ($database->get_result($target,$query)) {
               my $query_result = $database->get_result($target, $query, $searchengine);
               my $totalhits = $$query_result{TOTALHITS};
               my $mined = $$query_result{MINED};
               my $results = $$query_result{RESULTS};
                                             
                  $output .= "    |\n";
                  $output .= "    +---+ $searchengine\n";
                  $output .= "    |   |\n";                   
                  $output .= "    |   | Total Hits: $totalhits\n";
                  $output .= "    |   |\n";
                  $output .= "    |   +---+ Results\n";
                  foreach (@$mined) {
                  $output .= "    |   |     $_\n";
                  }
                  $output .= "    |   |\n";
                  $output .= "    |   +---+ Mined\n";
                  foreach (@$results) {
                  $output .= "    |         $_\n";
                  }
                  $output .= "    |\n";
               
            }
         }
      }
      
      print SAV $output;
      close SAV;
   }
}

###############################################################################
# Function   : txt_mined - generates just the mined pages report in txt
# Parameters : filename,database
# Returns    : none
sub txt_mined {
   my ($self,$filename,$database) = @_;
   if (defined $filename && defined $database) { 
   
      open(SAV, ">$filename") || print ("Couldn't save to $filename");
      print "Saving to $filename\n";
      
      my $timestamp = time;
            
      my $output =  "SEAT Report $timestamp\n";
         $output .= "======================\n\n";
      
      foreach my $target ($database->get_result) {
         $output .= "$target\n";
         $output .= "======================\n";
         foreach my $query ($database->get_result($target)) {
            foreach my $searchengine ($database->get_result($target,$query)) {
               my $query_result = $database->get_result($target, $query, $searchengine);
               my $mined = $$query_result{MINED};               

               my %mined_hash;
               foreach (@$mined) {
                  $mined_hash{$_} = undef;
               }
               foreach(sort keys %mined_hash) {
                  $output .= "$_\n";
               }             
            }
         }
      }      
      print SAV $output;
      close SAV;
   }
}

###############################################################################
# Function   : txt - generates just the page results report in txt
# Parameters : filename,database
# Returns    : none
sub txt_results {
   my ($self,$filename,$database) = @_;
   if (defined $filename && defined $database) { 
   
      open(SAV, ">$filename") || print ("Couldn't save to $filename");
      print "Saving to $filename\n";
      
      my $timestamp = time;
            
      my $output =  "SEAT Report $timestamp\n";
         $output .= "======================\n\n";
      
      foreach my $target ($database->get_result) {
         $output .= "$target\n";
         $output .= "======================\n";
         foreach my $query ($database->get_result($target)) {
            foreach my $searchengine ($database->get_result($target,$query)) {
               my $query_result = $database->get_result($target, $query, $searchengine);
               my $results = $$query_result{RESULTS};               

               my %results_hash;
               foreach (@$results) {
                  $results_hash{$_} = undef;
               }
               foreach (sort keys %results_hash) {
                  $output .= "$_\n";
               }          
            }
         }
      }      
      print SAV $output;
      close SAV;
   }
}

1;
