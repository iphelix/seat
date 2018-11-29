###############################################################################
# Package    : Connection
# Description: Established the actual connection to servers and returns
#              response collected from the query.
package Connection;

use strict;
use warnings;

use IO::Socket;

###############################################################################
# Function   : send_request - sends request to a server
# Parameters : none
# Returns    : Analysis object
sub send_request {
   my ($self,$server,$query,$useragent,$proxy,$worklog) = @_;
      
   my $port;
      
   if ($proxy) { 
      ($proxy,$port) = split(/:/,$proxy);
      unless($query =~ /^http:\/\//) { $query = "http://".$server.$query }
   }
   else {
      $proxy = $server;
      $port = 80;
   }
   
   # Generate random user-agent as requested   
   $useragent = $self->randomAgent($useragent, $worklog);
   
   $worklog->insert_msg("Using User-Agent: $useragent and Proxy: $proxy\n",'misc-info');
      
   # First prepare http request   
   my $message  = "GET $query HTTP/1.0\n";
   $message .= "Host: $server\n";
   $message .= "User-Agent: $useragent\n\n";
         
   my $socket = $self->socketInit($proxy, $port, $worklog);
   if($socket) {
      $socket->send($message);
   
      my @response;
   
      while (<$socket>) {
	   	push @response, $_;
	   }

      close $socket;
	   
	   return \@response;
	}
}


sub randomAgent {
   my ($self, $useragent, $worklog) = @_;
   if($useragent eq "Random Browser") {
      my $filename = "useragents/browser_list.txt";
      open(AGENT, $filename) || warn "could not open $filename";
      srand;
      my ($line,$name,$version);
      rand($.) < 1 && ($line = $_) while <AGENT>;
      ($name,$version,$useragent) = split(/\t/,$line); 
      close AGENT;
   }   
   if($useragent eq "Random Bot") {
      my $filename = "useragents/robots_list.txt";
      open(AGENT, $filename) || warn "could not open $filename";
      srand;
      my ($line,$name,$version);
      rand($.) < 1 && ($line = $_) while <AGENT>;
      ($name,$version,$useragent) = split(/\t/,$line); 
      close AGENT;
   }
   return $useragent;   
}

sub socketInit() {
   my ($self, $server, $port, $worklog) = @_;
   my $socket = IO::Socket::INET->new(
	   Proto => 'tcp',
	   PeerAddr => $server,
	   PeerPort => $port,
	   Timeout => 10,
   );

   if ($socket) {   
      $socket->autoflush(1);
      return $socket;
   } else {
      $worklog->insert_msg("Could not connect to $server:$port\n","error");
      return 0;
   }
}

1;
