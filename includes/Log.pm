###############################################################################
# Package    : Log
# Description: Specialized object for displaying information during execution
package Log;

use strict;
use warnings;

use Glib qw(TRUE FALSE);

use base 'Gtk2::ScrolledWindow';
use Gtk2::Pango;

###############################################################################
# Function   : new - instantiate new Log object
# Parameters : none
# Returns    : Log object
sub new {
	my $class = shift;

	my $self = Gtk2::ScrolledWindow->new;

	$self->set_shadow_type('etched-out');
	$self->set_policy('automatic','automatic');
	
	my $buffer = Gtk2::TextBuffer->new;
	$buffer->create_tag("info", foreground => "SteelBlue");
	$buffer->create_tag("misc-info", foreground => "MediumSeaGreen");
	$buffer->create_tag("notice", foreground => "orange");
	$buffer->create_tag("error", foreground => "darkred");
	$buffer->create_tag("SEAT", foreground => "red", style => "italic");
	
	my $view = Gtk2::TextView->new_with_buffer ($buffer);
	$view->set_editable(FALSE);
	$view->set_cursor_visible(FALSE);
	$view->set_wrap_mode("word");

	$self->add ($view);
	$view->set (editable => FALSE, cursor_visible => FALSE);

   my $msg = "SEAT is a tool intended for security professionals, Please act responsibly!\n";

   $buffer->insert_with_tags_by_name ($buffer->get_end_iter,$msg,'SEAT');   
	

	$self->{view} = $view;
	$self->{buffer} = $buffer;
	
	bless $self, $class;
		
	return $self;
}
  
###############################################################################
# Function   : insert_msg - inserts and displays new message.
#              There are 4 different message types:
#              info - information message
#              notice - notice message
#              error - error message
#              SEAT - special message SEAT message
# Parameters : message, message type
# Returns    : none
sub insert_msg {
	my ($self, $msg, $type) = @_;
	
	# add timestamp
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
        my $timestamp = sprintf "%4d-%02d-%02d %02d:%02d:%02d\n",$year+1900,$mon+1,$mday,$hour,$min,$sec;
	
        $msg = $timestamp." ".$msg;       

	my $buffer = $self->{buffer};
	
	Gtk2::Gdk::Threads->enter;
		
	my $iter = $buffer->get_end_iter;
	if(defined $type) { $buffer->insert_with_tags_by_name ($iter, $msg, $type); }
	else { $buffer->insert($iter,$msg); }
	
	$iter = $buffer->get_end_iter;
	$self->{view}->scroll_to_iter ($iter, 0.0, FALSE, 0.0, 0.0);
		
	Gtk2::Gdk::Threads->leave;
}
1;
