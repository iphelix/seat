###############################################################################
# Package    : QueryParser
# Description: Parses various signature databases to create new queries
package QueryParser;

###############################################################################
# Function   : parse - determines correct parser for the signature database
# Parameters : filename
# Returns    : queries and description hash
sub parse {
   my ($self, $filename) = @_;
   
   my %queries;
   
	if((defined $filename) && (-f $filename)) {
	   if($filename =~ /\.xml$/) {
	      %queries = $self->parse_ghdb($filename);
	   }
	   elsif($filename =~ /\.nikto$/) {
	      %queries = $self->parse_nikto($filename);
	   }
	   elsif($filename =~ /\.gs$/) {
	      %queries = $self->parse_gs($filename);
	   }	  
	   elsif($filename =~ /\.urlchk$/) {
	      %queries = $self->parse_urlchk($filename);
	   }	   
	   else {
	      %queries = $self->parse_simple($filename);
	   }
	}	
	return %queries;
}


###############################################################################
# Function   : parse_ghdb - parses Google Hacking Database
# Parameters : filename
# Returns    : queries and description hash
sub parse_ghdb {
   my ($self,$ghdb) = @_;
   
  	my $XML = XML::Smart->new($ghdb);
   $XML = $XML->cut_root;

  	my @signatures = @{$XML->{"signature"}};
  	my ($shortdescription, $querystring, $fulldescription);
   	  	
  	my %queries;

  	foreach(@signatures) {
	   # extract data from the database
  		$shortdescription = $_->{shortDescription};
  		$querystring = $_->{querystring};
  		$fulldescription = $_->{textualDescription};

  		# prepare description field
	   my $description = $fulldescription;
	   $queries{$querystring} = "$description";
   
  	}
  	return %queries;	
}

###############################################################################
# Function   : parse_urlchk - parses UrlChk Database
# Parameters : filename
# Returns    : queries and description hash
sub parse_urlchk {   
   my ($self,$urlchk) = @_;
   
	open(URLCHK, $urlchk) || warn "could not open $urlchk ﬁle";
	
	my %queries;
	
	my ($querystring, $description);
	
	while (<URLCHK>) {
	   if(/<get>(.*?)<\/get>/) { $querystring = "$1"; }
	   if(/<info>(.*?)<\/info>/) { $description = "$1"; }
	   if(/<\/url>/) {$queries{$querystring} = $description; }   
  	}
  	return %queries;
	
}

###############################################################################
# Function   : parse_nikto - parses nikto database
# Parameters : filename
# Returns    : queries and description hash
sub parse_nikto {
   my ($self,$nikto) = @_;
	open(NIKTO, $nikto) || warn "could not open the $nikto query ﬁle";
	
	my %queries;
	
	while (<NIKTO>) {
		chop;		           # stripping comments
		next if (/^$/);     # ignore null lines
		next if (/^\s*\#/); # ignore comment lines
		next if (/^\%/);    # ignore documentation lines
		
		# Spliting up the NIKTO database and storing elements
		my ($type, $attack, $file, $method, $description) = split(/","/);

		# Fix up root directories
		if($attack eq "/") { $attack = $file }

      $attack =~ s/\@CGIDIRS//; # remove scan variable
		$attack =~ s/^\s+//;      # remove leading whitespaces
		$attack =~ s/\s+$//;      # remove trailing whitespaces
	
		my $querystring = "inurl:$attack"; # prepare searchable form
		
		$queries{$querystring} = $description;
	}
	close NIKTO;
	return %queries;
}

###############################################################################
# Function   : gs database - parses gooscan database
# Parameters : filename
# Returns    : queries and description hash
sub parse_gs {
   my ($self,$gs) = @_;
	open(GS, $gs) || warn "could not open $gs query ﬁle";
	
	my %queries;
	
	while (<GS>) {
	   my $querystring;
	   my ($search_type,$search_string,$count,$description) = split(/\|/);
      
      if($search_type eq "raw")         { $querystring = $search_string }
      elsif($search_type eq "inurl")    { $querystring = "inurl:$search_string" }
      elsif($search_type eq "indexof")  { $querystring = "inurl:\"index of\" $search_string" }
      elsif($search_type eq "filetype") { $querystring = "filetype:$search_string" }
		
		$queries{$querystring} = $description;
	}
	close GS;
	return %queries;
}

###############################################################################
# Function   : parse_simple - parses simple text databases
# Parameters : filename
# Returns    : queries and description hash
sub parse_simple {
   my ($self,$simple) = @_;
	open(SIMPLE, $simple) || warn "could not open the $simple query ﬁle";
	
	my %queries;
	
	while (<SIMPLE>) {
		chop;		           #stripping comments
		next if (/^$/);     #ignore null lines
		next if (/^\s*\#/); # ignore comment lines
		
		my $querystring = "inurl:$_";
		
		$queries{$querystring} = "";
	}
	close SIMPLE;
	return %queries;
}
1;
