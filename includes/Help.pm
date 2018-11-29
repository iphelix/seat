###############################################################################
# Package    : Help
# Description: SEAT's extensive help system
package Help;

###############################################################################
# Function   : new - instantiates a new Database object
# Parameters : none
# Returns    : Database object
sub new {
	my ($class,$window) = @_;
	my $self = {
	   WINDOW => $window,
	};
	bless ($self, $class);
	return $self;
}

sub about {
   my $self = shift;
   my $window = $self->{WINDOW};
   my $about_dialog = Gtk2::Dialog->new('SEAT: v.0.3 Release', $window,'destroy-with-parent',
															'gtk-ok' => 'none');

	my $mrl_logo = Gtk2::Image->new_from_file("images/Mrl-logo.jpg");
	$about_dialog->vbox->add($mrl_logo);

	my $label = Gtk2::Label->new;
	$label->set_markup("<span><b>\nDeveloped by Peter Kacherginsky</b></span>");
	$about_dialog->vbox->add($label);	
	
	$about_dialog->vbox->add(Gtk2::Label->new("iphelix\@gmail.com"));

	$about_dialog->signal_connect (response => sub { $_[0]->destroy });
	$about_dialog->show_all;
}


sub help {
   my $self = shift;
   my $window = $self->{WINDOW};
     my $about_dialog = Gtk2::Dialog->new('SEAT: v.0.3 Release', $window,'destroy-with-parent',
															'gtk-ok' => 'none');

my $label = Gtk2::Label->new;
	$label->set_markup("<span><b>SEAT (Search Engine Assessment Tool)</b> is the next generation information digging
application geared toward the needs of security professionals. SEAT uses information
stored in search engine databases, cache repositories, and other public resources to
scan web sites for potential vulnerabilities. It's multi-threaded, multi-database,
and multi-search-engine capabilities permit easy navigation through vast amounts of
information with a goal of system security assessment. Furthermore, SEAT's ability to
easily process additional search engine signatures as well as custom made vulnerability
databases allows security professionals to adapt SEAT to their specific needs.

The overall assessment process is divided into three stages: <b>Preparation</b>, <b>Execution</b>,
and <b>Analysis</b>. This division allows you to concentrate on one task at hand and not be
overwhelmed or distracted by other tasks. Click on a respective tab in order to progress
through the assessment.:

In the <b>preparation</b> stage your primary goal is to specify a list of targets to analyze, 
as well as select one or more vulnerability databases that come with SEAT or manually add 
your own signature.

During the <b>execution</b> stage, you can specify details to how a particular scan will be performed. 
You can select and edit Search Engines used for the scan, adjust performance preferences, 
as well as simulate more realistic scans by using various Proxy Servers and User Agent 
identifiers. As SEAT runs, you can adjust preferences on the right panel live. Meaning 
whatever changes you makewill immediately take effect without restarting the scan.

In the <b>analysis</b> stage of the scan process, you will be presented with an easy navigation of the
collected results. You can mix and match different targets, signatures, and search engines to
learn the most about collected results.

For a complete manual see <b>SEAT Documentation.pdf</b> in the root installation directory.
If you are still stuck somewhere, feel free to contact me directly <i>iphelix\@gmail.com</i>.
</span>");
	$about_dialog->vbox->add($label);	
	
	$about_dialog->signal_connect (response => sub { $_[0]->destroy });
	$about_dialog->show_all;

}


1;
