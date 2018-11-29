###############################################################################
# Package    : Execution
# Description: Execution page of SEAT. Allows a user to select searchengines
#              used during the scan, configure execution parameters, and of
#              course start the scan itself.
package Execution;

use strict;
use warnings;

use Gtk2;
use base 'Gtk2::VBox';
use Glib qw(TRUE FALSE);

use XML::Smart;
use MIME::Base64;
use QueryGen;

use Worker;
use Log;

###############################################################################
# Function   : new - instantiate new Execution object
# Parameters : none
# Returns    : Execution object
sub new {
	my ($class, $database, $tooltips, $help) = @_;
	
	my $max_threads = 15;
	
	my $self = Gtk2::VBox->new(FALSE,0);	
	
	############################################################################
	# Execution Menubar
   my $menu_bar = Gtk2::MenuBar->new();

      ###############################################################################
      # Menu File
      my $menu_item_file = Gtk2::MenuItem->new('_File');
      my $file_menu = Gtk2::Menu->new();
      
      my $file_menu_searchengines_new = Gtk2::ImageMenuItem->new_with_label('New Search Engines');
      $file_menu_searchengines_new->set_image(Gtk2::Image->new_from_stock('gtk-new','menu'));
      $file_menu_searchengines_new->signal_connect('activate' => sub {
         $self->new_searchengine;
      });
      $file_menu->append($file_menu_searchengines_new);
      
      my $file_menu_searchengines_load = Gtk2::ImageMenuItem->new_with_label('Load Search Engines');
      $file_menu_searchengines_load->set_image(Gtk2::Image->new_from_stock('gtk-open','menu'));
      $file_menu_searchengines_load->signal_connect('activate' => sub {
         $self->open_searchengines;
      });
      $file_menu->append($file_menu_searchengines_load);
      
      my $file_menu_searchengines_save = Gtk2::ImageMenuItem->new_with_label('Save Search Engines');
      $file_menu_searchengines_save->set_image(Gtk2::Image->new_from_stock('gtk-save','menu'));
      $file_menu_searchengines_save->signal_connect('activate' => sub {
         $self->save_searchengines;
      });
      $file_menu->append($file_menu_searchengines_save);
      
      # add a separator
      $file_menu->append(Gtk2::SeparatorMenuItem->new());
            
      my $file_menu_preferences_load = Gtk2::ImageMenuItem->new_with_label('Load Preferences');
      $file_menu_preferences_load->set_image(Gtk2::Image->new_from_stock('gtk-open','menu'));
      $file_menu_preferences_load->signal_connect('activate' => sub {
         $self->open_preferences;
      });
      $file_menu->append($file_menu_preferences_load);
      
      my $file_menu_preferences_save = Gtk2::ImageMenuItem->new_with_label('Save Preferences');
      $file_menu_preferences_save->set_image(Gtk2::Image->new_from_stock('gtk-save','menu'));
      $file_menu_preferences_save->signal_connect('activate' => sub {
         $self->save_preferences;
      });
      $file_menu->append($file_menu_preferences_save);
          
      # add a separator
      $file_menu->append(Gtk2::SeparatorMenuItem->new());
      
      my $file_menu_exit = Gtk2::ImageMenuItem->new_from_stock('gtk-quit');
      $file_menu_exit->signal_connect('activate' => sub {
         Gtk2->main_quit;
      });
      $file_menu->append($file_menu_exit);
      
      $menu_item_file->set_submenu($file_menu);
      $menu_bar->append($menu_item_file);
      
      ###############################################################################
      # Menu Search Engines
      my $menu_item_searchengines = Gtk2::MenuItem->new('_Search Engines');
      my $searchengines_menu = Gtk2::Menu->new();
      
      my $searchengines_menu_add = Gtk2::ImageMenuItem->new_with_label('Add Search Engine');
      $searchengines_menu_add->set_image(Gtk2::Image->new_from_stock('gtk-add','menu'));
      $searchengines_menu_add->signal_connect('activate' => sub {
         $self->add_searchengine;
      });
      $searchengines_menu->append($searchengines_menu_add);
                   
      my $searchengines_menu_remove = Gtk2::ImageMenuItem->new_with_label('Remove Search Engine');
      $searchengines_menu_remove->set_image(Gtk2::Image->new_from_stock('gtk-remove','menu'));
      $searchengines_menu_remove->signal_connect('activate' => sub {
         $self->remove_searchengine;
      });
      $searchengines_menu->append($searchengines_menu_remove);  
      
      my $searchengines_menu_edit = Gtk2::ImageMenuItem->new_with_label('Edit Search Engine');
      $searchengines_menu_edit->set_image(Gtk2::Image->new_from_stock('gtk-edit','menu'));
      $searchengines_menu_edit->signal_connect('activate' => sub {
         $self->edit_searchengine;
      });
      $searchengines_menu->append($searchengines_menu_edit);
      
      # add a separator
      $searchengines_menu->append(Gtk2::SeparatorMenuItem->new());
      
      my $searchengines_menu_inverse = Gtk2::ImageMenuItem->new_with_label('Inverse');
      $searchengines_menu_inverse->set_image(Gtk2::Image->new_from_stock('gtk-justify-center','menu'));
      $searchengines_menu_inverse->signal_connect('activate' => sub {
         $self->inverse_searchengine;
      });
      $searchengines_menu->append($searchengines_menu_inverse);
      
      my $searchengines_menu_selectall = Gtk2::ImageMenuItem->new_with_label('Select All');
      $searchengines_menu_selectall->set_image(Gtk2::Image->new_from_stock('gtk-justify-fill','menu'));
      $searchengines_menu_selectall->signal_connect('activate' => sub {
         $self->selectall_searchengine;
      });
      $searchengines_menu->append($searchengines_menu_selectall);
      
      my $searchengines_menu_deselectall = Gtk2::ImageMenuItem->new_with_label('Deselect All');
      $searchengines_menu_deselectall->set_image(Gtk2::Image->new_from_stock('gtk-file','menu'));
      $searchengines_menu_deselectall->signal_connect('activate' => sub {
         $self->deselectall_searchengine;
      });
      $searchengines_menu->append($searchengines_menu_deselectall);
   
      $menu_item_searchengines->set_submenu($searchengines_menu);
      $menu_bar->append($menu_item_searchengines);
      
      ###############################################################################
      # Menu Execution
      my $menu_item_execution = Gtk2::MenuItem->new('E_xecution');
      my $execution_menu = Gtk2::Menu->new();
      
      my $execution_menu_start = Gtk2::ImageMenuItem->new_with_label('Start');
      $execution_menu_start->set_image(Gtk2::Image->new_from_stock('gtk-execute','menu'));
      $execution_menu_start->signal_connect('activate' => sub {
         $self->start;
      });
      $execution_menu->append($execution_menu_start);
      
      my $execution_menu_pause = Gtk2::ImageMenuItem->new_with_label('Pause');
      $execution_menu_pause->set_image(Gtk2::Image->new_from_stock('gtk-media-pause','menu'));
      $execution_menu_pause->signal_connect('activate' => sub {
         $self->pause;
      });
      $execution_menu->append($execution_menu_pause);
      
      my $execution_menu_stop = Gtk2::ImageMenuItem->new_with_label('Stop');
      $execution_menu_stop->set_image(Gtk2::Image->new_from_stock('gtk-stop','menu'));
      $execution_menu_stop->signal_connect('activate' => sub {
         $self->stop;
      });
      $execution_menu->append($execution_menu_stop);
      
      $menu_item_execution->set_submenu($execution_menu);
      $menu_bar->append($menu_item_execution);     
      
      ###############################################################################
      # Menu Help
      my $menu_item_help = Gtk2::MenuItem->new('_Help');
      $menu_item_help->set_right_justified(TRUE);
      my $help_menu = Gtk2::Menu->new();

      # Content Menu Item
      my $help_menu_content = Gtk2::ImageMenuItem->new_from_stock('gtk-help',undef);
      $help_menu_content->signal_connect('activate' => sub {$help->help}) ;
      $help_menu->append($help_menu_content);			
   
      $help_menu->append(Gtk2::SeparatorMenuItem->new());

      # About Menu Item
      my $help_menu_about = Gtk2::ImageMenuItem->new_from_stock('gtk-about',undef);
      $help_menu_about->signal_connect('activate' => sub {
         $help->about;
      });
      $help_menu->append($help_menu_about);
      $menu_item_help->set_submenu($help_menu);
      $menu_bar->append($menu_item_help);
      
   $self->pack_start($menu_bar,FALSE,TRUE,0);
	
	my $execution = Gtk2::HBox->new(FALSE,0);
	
	############################################################################
	# Search Engines
	my $searchengines = Gtk2::VBox->new(FALSE,0);
	$searchengines->set_size_request('215',);
	
	my $searchengines_list;	
	
	############################################################################
	# Search Engines Toolbar
	my $searchengines_toolbar = Gtk2::Toolbar->new();
	$searchengines_toolbar->set_icon_size('menu');
	$searchengines_toolbar->set_style('icons');
	$searchengines_toolbar->set_tooltips(TRUE);
	
	   #########################################################################
		# Add Search Engine
		my $searchengines_add = Gtk2::ToolButton->new_from_stock('gtk-add');
		$searchengines_add->signal_connect('clicked' => sub {
		   $self->add_searchengine;
		});
		$searchengines_add->set_tooltip($tooltips,"Add a new searchengine","");
		$searchengines_toolbar->insert($searchengines_add,-1);
	
	   #########################################################################
		# Remove a Search Engine Button
		my $searchengines_remove = Gtk2::ToolButton->new_from_stock('gtk-remove');
		$searchengines_remove->signal_connect('clicked' => sub {		
		   $self->remove_searchengine;
		});
		$searchengines_remove->set_tooltip($tooltips,"Remove selected searchengine","");
		$searchengines_toolbar->insert($searchengines_remove,-1);

      #########################################################################
		# Edit Search Engine Button
		my $searchengines_edit = Gtk2::ToolButton->new_from_stock('gtk-edit');
		$searchengines_edit->signal_connect('clicked' => sub {		
         $self->edit_searchengine;
		});		
		$searchengines_edit->set_tooltip($tooltips,"Edit selected searchengine","");
		$searchengines_toolbar->insert($searchengines_edit,-1);
		
		#########################################################################
		# New Search Engine List Button
		my $searchengines_new = Gtk2::ToolButton->new_from_stock('gtk-new');
		$searchengines_new->signal_connect('clicked' => sub {   
		   $self->new_searchengine;
		});
		$searchengines_new->set_tooltip($tooltips,"Create a new searchengines list","");
		$searchengines_toolbar->insert($searchengines_new,-1);

      #########################################################################
   	# Open Search Engine List Button 
		my $searchengines_open = Gtk2::ToolButton->new_from_stock('gtk-open');
		$searchengines_open->signal_connect('clicked' => sub {
			$self->open_searchengines;
		});		
		$searchengines_open->set_tooltip($tooltips,"Load searchengines from a file","");
		$searchengines_toolbar->insert($searchengines_open,-1);
		
		#########################################################################
		# Save Search Engine List Button 
		my $searchengines_save = Gtk2::ToolButton->new_from_stock('gtk-save');
		$searchengines_save->signal_connect('clicked' => sub {
			$self->save_searchengines;
		});
		$searchengines_save->set_tooltip($tooltips,"Save searchengines to a file","");
		$searchengines_toolbar->insert($searchengines_save,-1);
		
		#########################################################################
		# Inverse Search Engine List Selection Button
		my $searchengines_inverse = Gtk2::ToolButton->new_from_stock('gtk-justify-fill');
		$searchengines_inverse->signal_connect('clicked' => sub {		
         $self->inverse_searchengine;
		});		
		$searchengines_inverse->set_tooltip($tooltips,"Inverse searchengine list selection","");
		$searchengines_toolbar->insert($searchengines_inverse,-1);

	$searchengines->pack_start($searchengines_toolbar,FALSE,FALSE,0);

	############################################################################
	# Searchengines Frame
	my $searchengines_frame = Gtk2::Frame->new();

		# Searchengines Scrolled Window
		my $searchengines_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$searchengines_sw->set_policy('automatic','automatic');

		$searchengines_list = Gtk2::SimpleList->new (
			"" => 'bool',
			"Search Engines" => 'text',
		);
		
		# Enable searching
		$searchengines_list->set_search_column(1);
		
   	# Enable sorting
		my $searchengines_column = $searchengines_list->get_column (1);
		$searchengines_column->set_sort_column_id(1);
		
		# Connect signal to delete key
		$searchengines_list->signal_connect(key_press_event => sub {	   
	  	   my($widget, $event) = @_;
	      if($event->keyval == $Gtk2::Gdk::Keysyms{Delete} || $event->keyval == $Gtk2::Gdk::Keysyms{BackSpace} || $event->keyval == $Gtk2::Gdk::Keysyms{KP_Delete}) {
			   my @selected = $searchengines_list->get_selected_indices;
   			foreach my $index (@selected) {
	   		   $database->searchengine_remove(@{$searchengines_list->{data}}[$index]->[1]);
	   			splice @{$searchengines_list->{data}}, $index, 1;
	   		}
	      }	   
	  	});
	
		# Connect signal to checkbox
		my $searchengines_cell = ($searchengines_list->get_column (0)->get_cell_renderers)[0];
		$searchengines_cell->signal_connect (toggled => sub {
		my ($cell, $text_path) = @_;
		my $active = ($searchengines_cell->get_active ? 0 : 1);
	   	my $name = @{$searchengines_list->{data}}[$text_path]->[1];
	   	$database->searchengine($name,$active);
		});	
		$searchengines_sw->add($searchengines_list);
		$searchengines_frame->add($searchengines_sw);	
	
	$searchengines->pack_start($searchengines_frame,TRUE,TRUE,0);
	$execution->pack_start($searchengines,FALSE,FALSE,0);	
	
   ############################################################################
   # Execute Frame
   my $running = Gtk2::VBox->new(FALSE,0);
   
   my $controls = Gtk2::HBox->new(FALSE,0);
   
   my ($querygen,$worklog);
      
   ############################################################################
   # Start execution   
   my $start_button = Gtk2::Button->new_from_stock('gtk-execute');
   $start_button->signal_connect('clicked' => sub {
      $self->start;
   });
   $tooltips->set_tip($start_button,"Start execution");
   $controls->pack_start($start_button, TRUE,TRUE,0);
      
   ############################################################################
   # Pause execution   
   my $pause_button = Gtk2::Button->new_from_stock('gtk-media-pause');
   $pause_button->signal_connect('clicked' => sub {
      $self->pause;
   });
   $tooltips->set_tip($pause_button,"Pause execution");
   $controls->pack_start($pause_button, TRUE,TRUE,0);
   
   ############################################################################
   # Stop execution
   my $stop_button = Gtk2::Button->new_from_stock('gtk-stop');
   $stop_button->signal_connect('clicked' => sub {
      $self->stop;
   });
   $tooltips->set_tip($stop_button,"Stop execution");
   $controls->pack_start($stop_button, TRUE,TRUE,0);   
   $running->pack_start($controls,FALSE,FALSE,0);
   
   
   ############################################################################
	# Logging
	$worklog = Log->new;
	$running->pack_start($worklog,TRUE,TRUE,0);	
   
   $execution->pack_start($running,TRUE,TRUE,0);
   
	############################################################################
	# Preferences
	my $preferences = Gtk2::VBox->new(FALSE,0);
	$preferences->set_size_request('215',);

	############################################################################
	# Preferences Toolbar
	my $preferences_toolbar = Gtk2::Toolbar->new();
	$preferences_toolbar->set_icon_size('menu');
	$preferences_toolbar->set_style('icons');
	$preferences_toolbar->set_tooltips(TRUE);
	
	   #########################################################################
		# Load Preferences
		my $preferences_open = Gtk2::ToolButton->new_from_stock('gtk-open');
		$preferences_open->signal_connect('clicked' => sub {
		   $self->open_preferences;
		});
		$preferences_open->set_tooltip($tooltips,"Load preferences from a file","");
		$preferences_toolbar->insert($preferences_open,-1);

      #########################################################################
		# Save preferences
		my $preferences_save = Gtk2::ToolButton->new_from_stock('gtk-save');
		$preferences_save->signal_connect('clicked' => sub {
		   $self->save_preferences;
		});
		$preferences_save->set_tooltip($tooltips,"Save preferences to a file","");
		$preferences_toolbar->insert($preferences_save,-1);

	$preferences->pack_start($preferences_toolbar,FALSE,FALSE,0);

	############################################################################
	# Preferences Frame
	my $preferences_frame = Gtk2::Frame->new();
      my $preferences_sw = Gtk2::ScrolledWindow->new(undef,undef);
         $preferences_sw->set_policy('never', 'automatic');
		my $preferences_vbox = Gtk2::VBox->new(FALSE,0);
		
		my $preferences_label = Gtk2::Label->new;
		$preferences_label->set_markup("<span><big><b>Preferences</b></big></span>");
		$preferences_vbox->pack_start($preferences_label,FALSE,FALSE,0);
		
		#########################################################################
		# Search Depth
		$preferences_vbox->pack_start(Gtk2::Label->new("Search depth"),FALSE,FALSE,0); 
		my $depth_combo = Gtk2::ComboBoxEntry->new_text;
		foreach(0..10) { $depth_combo->append_text($_); }
      ($depth_combo->child)->signal_connect('changed' => sub {
        	my ($entry) = @_;
        	$database->preferences_depth($entry->get_text);
  	   });
		$preferences_vbox->pack_start($depth_combo,FALSE,FALSE,0);
		
		$self->{DEPTH} = $depth_combo;
		
		#########################################################################
		# Use Mined Results
		$preferences_vbox->pack_start(Gtk2::Label->new("\nUse mined results"),FALSE,FALSE,0);	
		my $mined_combo = Gtk2::ComboBox->new_text;
	   $mined_combo->append_text("Never");
      $mined_combo->append_text("Save for Later");
      $mined_combo->append_text("Immediately Request");
   	$mined_combo->signal_connect('changed' => sub {
   	   $database->preferences_mined($mined_combo->get_active); 
   	});
		$preferences_vbox->pack_start($mined_combo,FALSE,FALSE,0);

      $self->{MINED} = $mined_combo;
		
		#########################################################################
		# Sleep time
		$preferences_vbox->pack_start(Gtk2::Label->new("\nSleep time between runs"),FALSE,FALSE,0); 
		my $sleep_combo = Gtk2::ComboBoxEntry->new_text;		
      foreach(0..10) { $sleep_combo->append_text($_); }
      ($sleep_combo->child)->signal_connect('changed' => sub {
      	my ($entry) = @_;
         $database->preferences_sleep($entry->get_text);
      });   
		$preferences_vbox->pack_start($sleep_combo,FALSE,FALSE,0);	

      $self->{SLEEP} = $sleep_combo;
			
		#########################################################################	
		# Number of threads
		$preferences_vbox->pack_start(Gtk2::Label->new("\nNumber of threads"),FALSE,FALSE,0); 
		my $threads_combo = Gtk2::ComboBox->new_text;
   	foreach(1..$max_threads) { $threads_combo->append_text($_); }
      $threads_combo->signal_connect('changed' => sub {
      	$database->preferences_threads($threads_combo->get_active_text);
   	});	
		$preferences_vbox->pack_start($threads_combo,FALSE,FALSE,0);
		
		$self->{THREADS} = $threads_combo;

      #########################################################################
		# User agents
		$preferences_vbox->pack_start(Gtk2::Label->new("\nUser Agent"),FALSE,FALSE,0); 
		my $useragent_combo = Gtk2::ComboBoxEntry->new_text;
      $useragent_combo->append_text("SEAT");		  
	   $useragent_combo->append_text("GoogleBot");		  
	   $useragent_combo->append_text("MSNBot");			  
	   $useragent_combo->append_text("Slurp");		  
	   $useragent_combo->append_text("Random Bot");		  
	   $useragent_combo->append_text("Random Browser"); 
	   ($useragent_combo->child)->signal_connect('changed' => sub {
      	my ($entry) = @_;
	      $database->preferences_useragent($entry->get_text);
	   });	
		$preferences_vbox->pack_start($useragent_combo,FALSE,FALSE,0);
      $self->{USERAGENT} = $useragent_combo;

      #########################################################################
		# Proxy Server
		$preferences_vbox->pack_start(Gtk2::Label->new("\nUse Proxy Server"),FALSE,FALSE,0);
		my $proxy_entry = Gtk2::Entry->new;
		$proxy_entry->signal_connect('changed' => sub {
		   $database->preferences_proxy($proxy_entry->get_text);		
		});
		$preferences_vbox->pack_start($proxy_entry,FALSE,FALSE,0);	
		
		$self->{PROXY} = $proxy_entry;
		
		$preferences_sw->add_with_viewport($preferences_vbox);
		$preferences_frame->add($preferences_sw);	
	
	$preferences->pack_start($preferences_frame,TRUE,TRUE,0);
	$execution->pack_start($preferences,FALSE,FALSE,0);	
	
	$self->pack_start($execution,TRUE,TRUE,0);
	
	############################################################################
	# Worker Threads
	# TODO: make the number of threads dynamic according to the config file
	my $threads_sw = Gtk2::ScrolledWindow->new(undef,undef);
	$threads_sw->set_policy('automatic','never');
	$threads_sw->set_size_request(0,'120');
	my $threads = Gtk2::HBox->new(TRUE,0);
	
	my @workers;
	
   foreach (1..$max_threads)
   {
	   if($_ < 10) { $_ = "0".$_ }
   	my $worker = Worker->new ($worklog,$database);
   	$threads->pack_start ($worker, FALSE, FALSE, 0);
   	$worker->set_worker_label ($_);
   	push @workers, $worker;
   }
       
   $threads->show_all;
      
   $threads_sw->add_with_viewport($threads);
	
	$self->pack_start($threads_sw,FALSE,TRUE,0);
	
	my $progress = Gtk2::ProgressBar->new;
	$progress->set_size_request(0,25);
	$self->pack_start($progress,FALSE,TRUE,0);
	
	############################################################################
	# Update jobs pending
	my $max_jobs = 0;
	Glib::Timeout->add (500, sub {
   	my $jobs_pending =  Worker->jobs_pending;
		$progress->set_text ($jobs_pending.' jobs pending');
		
		if($jobs_pending > $max_jobs) {$max_jobs = $jobs_pending }
		
		if($max_jobs && $jobs_pending) {
		   $progress->set_fraction(($max_jobs - $jobs_pending)/$max_jobs);
		}
		else {
		   $max_jobs = 0;
		   $progress->set_fraction(0);
		}
		
     	1;
   });
   
	############################################################################
	# Initialize common variables
   $self->{SEARCH_ENGINES} = $searchengines_list;
	$self->{DATABASE} = $database;
	$self->{WORKLOG} = $worklog;
	
	############################################################################
	# Instantiate object		
	bless $self, $class;
	
	############################################################################
	# Pre-load default search engine list
	$self->open_searchengines("searchengines/default.xml");
	$self->open_preferences("preferences/default.conf");
	
	return $self;
}

###############################################################################
# Function   : add_searchengine - adds / edits search engine to the list
# Parameters : search engine name
# Returns    : none
sub add_searchengine {
	my ($self, $se_name) = @_;
	my $searchengines_list = $self->{SEARCH_ENGINES};
	my $database = $self->{DATABASE};
	
	my $parent = $self->get_parent->get_parent->get_parent;

	my $dialog = Gtk2::Dialog->new("SEAT: Search Engine",$parent,'destroy-with-parent',
											 'gtk-add'   => 'accept',
											 'gtk-cancel' => 'cancel');
								
	############################################################################										 
	# First get user input
	my $se_hbox = Gtk2::HBox->new(FALSE,0);	
	my $se_desc_vbox = Gtk2::VBox->new(FALSE,0);
	my $se_entry_vbox = Gtk2::VBox->new(FALSE,0);
	$se_entry_vbox->set_size_request('300',);

	# Search Engine Name
	my $name_label = Gtk2::Label->new("Name:");
	$name_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($name_label,TRUE,TRUE,0);
	my $name = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($name,TRUE,TRUE,0);

	# Search Engine Prefix
	my $prefix_label = Gtk2::Label->new("Prefix:");
	$prefix_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($prefix_label,TRUE,TRUE,0);
	my $prefix = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($prefix,TRUE,TRUE,0);

	# Search Engine Server
	my $server_label = Gtk2::Label->new("Server:");
	$server_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($server_label,TRUE,TRUE,0);
	my $server = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($server,TRUE,TRUE,0);
	
	# Search Engine Matchstring
	my $matchstring_label = Gtk2::Label->new("Matchstring:");
	$matchstring_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($matchstring_label,TRUE,TRUE,0);
	my $matchstring = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($matchstring,TRUE,TRUE,0);
	
	# Search Engine Results Matchstring
	my $results_matchstring_label = Gtk2::Label->new("Results Matchstring:");
	$results_matchstring_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($results_matchstring_label,TRUE,TRUE,0);
	my $results_matchstring = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($results_matchstring,TRUE,TRUE,0);
	
	# Search Engine Next Matchstring
	my $next_matchstring_label = Gtk2::Label->new("Next Matchstring:");
	$next_matchstring_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($next_matchstring_label,TRUE,TRUE,0);
	my $next_matchstring = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($next_matchstring,TRUE,TRUE,0);
	
	# Search Engine Cache Matchstring
	my $cache_matchstring_label = Gtk2::Label->new("Cache Matchstring:");
	$cache_matchstring_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($cache_matchstring_label,TRUE,TRUE,0);
	my $cache_matchstring = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($cache_matchstring,TRUE,TRUE,0);
	
	# Search Engine Site
	my $site_label = Gtk2::Label->new("Site:");
	$site_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($site_label,TRUE,TRUE,0);
	my $site = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($site,TRUE,TRUE,0);
	
	# Search Engine IP
	my $ip_label = Gtk2::Label->new("IP:");
	$ip_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($ip_label,TRUE,TRUE,0);
	my $ip = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($ip,TRUE,TRUE,0);
	
	# Search Engine In Title
	my $intitle_label = Gtk2::Label->new("In Title:");
	$intitle_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($intitle_label,TRUE,TRUE,0);
	my $intitle = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($intitle,TRUE,TRUE,0);
	
	# Search Engine In URL
	my $inurl_label = Gtk2::Label->new("In URL:");
	$inurl_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($inurl_label,TRUE,TRUE,0);
	my $inurl = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($inurl,TRUE,TRUE,0);
	
	# Search Engine Filetype
	my $filetype_label = Gtk2::Label->new("Filetype:");
	$filetype_label->set_alignment(1,.5);
	$se_desc_vbox->pack_start($filetype_label,TRUE,TRUE,0);
	my $filetype = Gtk2::Entry->new;
	$se_entry_vbox->pack_start($filetype,TRUE,TRUE,0);
		
	############################################################################	
	# Second load variables for predefined search engine
	if(defined $se_name) {
	   $name->set_text($se_name);
	   
	   my $searchengine = $database->searchengine($se_name);
	   $prefix->set_text($$searchengine{prefix});
	   $server->set_text($$searchengine{server});
	   $matchstring->set_text($$searchengine{matchstring});
	   $results_matchstring->set_text($$searchengine{results_matchstring});
	   $next_matchstring->set_text($$searchengine{next_matchstring});
	   $cache_matchstring->set_text($$searchengine{cache_matchstring});
	   $site->set_text($$searchengine{site});
	   $ip->set_text($$searchengine{ip});
	   $intitle->set_text($$searchengine{intitle});
	   $inurl->set_text($$searchengine{inurl});
	   $filetype->set_text($$searchengine{filetype});
	}
	
   $se_hbox->pack_start($se_desc_vbox,FALSE,FALSE,0);
   $se_hbox->pack_start($se_entry_vbox,TRUE,TRUE,0);   

	$dialog->vbox->add($se_hbox);
	$dialog->show_all;
	
	############################################################################
	# Third put new/modified search engine into the database
	$dialog->signal_connect(response => sub {
		if($_[1] =~ m/accept/){
		   $database->searchengine($name->get_text, 
		                           1, 
		                           $prefix->get_text, 
		                           $server->get_text, 
		                           $matchstring->get_text, 
		                           $results_matchstring->get_text, 
		                           $next_matchstring->get_text, 
		                           $cache_matchstring->get_text, 
		                           $site->get_text, 
		                           $ip->get_text, 
		                           $intitle->get_text, 
		                           $inurl->get_text, 
		                           $filetype->get_text, 
		   );
		   foreach (@{$searchengines_list->{data}}) { if(@$_[1] eq $name->get_text) { return } }
		   push @{$searchengines_list->{data}}, [TRUE, $name->get_text];
		}
		else {
			$dialog->destroy;
		}
	});
}

###############################################################################
# Function   : remove_searchengine - remove a search engine from the list
# Parameters : none
# Returns    : none
sub remove_searchengine {
   my $self = shift;   
	my $searchengines_list = $self->{SEARCH_ENGINES};
	my $database = $self->{DATABASE};

	my @selected = $searchengines_list->get_selected_indices;
	foreach my $index (@selected) {
	   $database->searchengine_remove(@{$searchengines_list->{data}}[$index]->[1]);
		splice @{$searchengines_list->{data}}, $index, 1;
	}
}

###############################################################################
# Function   : edit_searchengine - edit selected search engine signature
# Parameters : none
# Returns    : none
sub edit_searchengine {
   my $self = shift;   
	my $searchengines_list = $self->{SEARCH_ENGINES};
	my $database = $self->{DATABASE};

	my @selected = $searchengines_list->get_selected_indices;
	foreach my $index (@selected) {
      $self->add_searchengine(${$searchengines_list->{data}}[$index]->[1]);
	}
}

###############################################################################
# Function   : new_searchengine - creates new search engine list
# Parameters : search engine name
# Returns    : none
sub new_searchengine {
   my $self = shift;   
	my $searchengines_list = $self->{SEARCH_ENGINES};
	my $database = $self->{DATABASE};

	@{$searchengines_list->{data}} = ();
	$database->searchengine_purge;
}

###############################################################################
# Function    : open_searchengines - load search engine signatures from file
# Parameters  : filename
# Returns     : none
sub open_searchengines {
   my ($self, $searchenginedb) = @_;
   
   my $searchengines_list = $self->{SEARCH_ENGINES};
	my $database = $self->{DATABASE};
   
   unless (defined $searchenginedb) {   
   	my $file_chooser = Gtk2::FileChooserDialog->new(
	   	'Open', undef, 'open',
	   	'gtk-ok' => 'ok',
	   	'gtk-cancel' => 'cancel',
	   );   
   	my $sedb_filter = Gtk2::FileFilter->new;
	   $sedb_filter->set_name("Search Engine Database");
	   $sedb_filter->add_pattern("*.xml");
	   $file_chooser->add_filter($sedb_filter);
   
      if('ok' eq $file_chooser->run) {
	   	$searchenginedb = $file_chooser->get_filename;
	   }	   
	   $file_chooser->destroy;
	
	}
	
	if(defined $searchenginedb) {      
      my %searchengines;
         
      my $XML = XML::Smart->new($searchenginedb);
      $XML = $XML->cut_root;
      
      my @searchengines = @{$XML->{"searchEngine"}};
      foreach (@{$XML->{"searchEngine"}}) {
         my($name, $prefix, $server, $matchstring, $results_matchstring, $next_matchstring, $cache_matchstring, $site, $ip, $intitle, $inurl, $filetype);
         
         ######################################################################
         # First extract data from XML file
         $name = $_->{searchEngineName};
         $prefix = decode_base64($_->{searchEnginePrefix});
         $server = $_->{searchEngineServer};
         $matchstring = decode_base64($_->{searchEngineMatchstring});
         $results_matchstring = decode_base64($_->{searchEngineResultsMatchstring});
         $next_matchstring = decode_base64($_->{searchEngineNextMatchstring});
         $cache_matchstring = decode_base64($_->{searchEngineCacheMatchstring});
         $site = decode_base64($_->{searchEngineSite});
         $ip = decode_base64($_->{searchEngineIp});
         $intitle = decode_base64($_->{searchEngineIntitle});
         $inurl = decode_base64($_->{searchEngineInurl});
         $filetype = decode_base64($_->{searchEngineFiletype});
               
         ######################################################################      
         # Second load that data into the searchengines hash      
         $searchengines{$name} = {
            active => 1,
            prefix => "$prefix",
            server => "$server",
            matchstring => "$matchstring",
            results_matchstring => "$results_matchstring",
            next_matchstring => "$next_matchstring",
            cache_matchstring => "$cache_matchstring",
            site => "$site",
            ip => "$ip",
            intitle => "$intitle",
            inurl => "$inurl",
            filetype => "$filetype",
         };
      }
   
	   $database->searchengines(%searchengines);
   	foreach ($database->searchengines_list) {
	      push @{$searchengines_list->{data}}, [TRUE, $_];
      }   
   }
}

###############################################################################
# Function   : save_searchengines - saves searchengines to a signature file
# Parameters : none
# Returns    : none
sub save_searchengines {
   my $self = shift;
   my $database = $self->{DATABASE};
   my @searchengines = $database->searchengines_list;
   
   my $file_chooser = Gtk2::FileChooserDialog->new(
		'Save', undef, 'save',
		'gtk-ok' => 'ok',
		'gtk-cancel' => 'cancel',
	);
	
	my $filename;

	if('ok' eq $file_chooser->run) {
		$filename = $file_chooser->get_filename;
	}
	$file_chooser->destroy;
   
   if(defined $filename) {
		open(SAV, ">$filename") || print "Couldn't open $filename\n";
		print SAV "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
		print SAV "<searchEngineSignature>\n";
		
      foreach (@searchengines) {	      
	      ######################################################################
	      # Prepare search engine signature
	      my $searchengine = $database->searchengine($_);
         my $name = $$searchengine{name};
	      my $prefix = $$searchengine{prefix};
	      my $server = $$searchengine{server};
	      my $matchstring = $$searchengine{matchstring};
	      my $results_matchstring = $$searchengine{results_matchstring};
	      my $next_matchstring = $$searchengine{next_matchstring};
	      my $cache_matchstring = $$searchengine{cache_matchstring};
	      my $site = $$searchengine{site};
	      my $ip = $$searchengine{ip};
	      my $intitle = $$searchengine{intitle};
	      my $inurl = $$searchengine{inurl};
	      my $filetype = $$searchengine{filetype};
	
	      ######################################################################
	      # Encode strings that might cause trouble
      	$prefix = encode_base64($prefix);
      	$matchstring = encode_base64($matchstring);
      	$results_matchstring = encode_base64($results_matchstring);
      	$next_matchstring = encode_base64($next_matchstring);
      	$cache_matchstring = encode_base64($cache_matchstring);
      	$site = encode_base64($site);
      	$ip = encode_base64($ip);
      	$intitle = encode_base64($intitle);
      	$inurl = encode_base64($inurl);
      	$filetype = encode_base64($filetype);
   
         ######################################################################
         # Write XML to file
      	print SAV "<searchEngine>\n";
      	print SAV "\t<searchEngineName>$_</searchEngineName>\n";
      	print SAV "\t<searchEnginePrefix>$prefix</searchEnginePrefix>\n";
      	print SAV "\t<searchEngineServer>$server</searchEngineServer>\n";
      	print SAV "\t<searchEngineMatchstring>$matchstring</searchEngineMatchstring>\n";
      	print SAV "\t<searchEngineResultsMatchstring>$results_matchstring</searchEngineResultsMatchstring>\n";
      	print SAV "\t<searchEngineNextMatchstring>$next_matchstring</searchEngineNextMatchstring>\n";
      	print SAV "\t<searchEngineCacheMatchstring>$cache_matchstring</searchEngineCacheMatchstring>\n";
      	print SAV "\t<searchEngineSite>$site</searchEngineSite>\n";
      	print SAV "\t<searchEngineIp>$ip</searchEngineIp>\n";
      	print SAV "\t<searchEngineIntitle>$intitle</searchEngineIntitle>\n";
      	print SAV "\t<searchEngineInurl>$inurl</searchEngineInurl>\n";
      	print SAV "\t<searchEngineFiletype>$filetype</searchEngineFiletype>\n";
      	print SAV "</searchEngine>\n";
      
      }
      print SAV "</searchEngineSignature>\n";
	   close SAV;
	}
}

sub inverse_searchengine {
   my $self = shift;
   
   my $database = $self->{DATABASE};
   my $searchengines_list = $self->{SEARCH_ENGINES};
   
   foreach (@{$searchengines_list->{data}}) {
   	$_->[0] = !$_->[0];
		$database->searchengine($_->[1],$_->[0]);
	}
}

sub selectall_searchengine {
   my $self = shift;
   
   my $database = $self->{DATABASE};
   my $searchengines_list = $self->{SEARCH_ENGINES};
   
   foreach (@{$searchengines_list->{data}}) {
   	$_->[0] = 1;
		$database->searchengine($_->[1],$_->[0]);
	}
}

sub deselectall_searchengine {
   my $self = shift;
   
   my $database = $self->{DATABASE};
   my $searchengines_list = $self->{SEARCH_ENGINES};
   
   foreach (@{$searchengines_list->{data}}) {
   	$_->[0] = 0;
		$database->searchengine($_->[1],$_->[0]);
	}
}

sub open_preferences {
   my ($self,$preferences_file) = @_;
   
   use vars qw($depth $use_mined $sleep $nthreads $useragent $proxy);
   
   unless (defined $preferences_file) {   
   	my $file_chooser = Gtk2::FileChooserDialog->new(
	   	'Open', undef, 'open',
	   	'gtk-ok' => 'ok',
	   	'gtk-cancel' => 'cancel',
	   );   
   	my $pref_filter = Gtk2::FileFilter->new;
	   $pref_filter->set_name("conf");
	   $pref_filter->add_pattern("*.conf");
	   $file_chooser->add_filter($pref_filter);
   
      if('ok' eq $file_chooser->run) {
	   	$preferences_file = $file_chooser->get_filename;
	   }	   
	   $file_chooser->destroy;
	}
	
	do $preferences_file;
	
   
   ############################################################################
   # Set GUI parameters
   # TODO: make this smarter and add more flexible user-specified ranges
   
   my $database = $self->{DATABASE};
   
   # Depth
   my $depth_combo = $self->{DEPTH};
   if($depth > 10) { $depth = 10; }
   $depth_combo->set_active($depth);
   $database->preferences_depth($depth);
   
   # Mined
   my $mined_combo = $self->{MINED};
   if($use_mined > 2) { $use_mined = 0; }
   $mined_combo->set_active($use_mined);
   $database->preferences_mined($use_mined);
	
	# Sleep
	my $sleep_combo = $self->{SLEEP};
	if($sleep > 10) { $sleep = 10; }
	$sleep_combo->set_active($sleep);
	$database->preferences_sleep($sleep);
	
	# Threads
	my $threads_combo = $self->{THREADS};
	if($nthreads > 15) { $nthreads = 15; }
	$threads_combo->set_active($nthreads-1);
	$database->preferences_threads($nthreads);
	
	# Useragent
	my $useragent_combo = $self->{USERAGENT};
	my %useragents = (
	   SEAT		      => 0,
	   GoogleBot		=> 1,
	   MSNBot			=> 2,
	   Slurp	         => 3,
	   'Random Bot'		=> 4,
	   'Random Browser' => 5,
	); 	   
	$useragent_combo->set_active($useragents{$useragent});
	$database->preferences_useragent($useragent);
	
	# Proxy
	my $proxy_entry = $self->{PROXY};
	$proxy_entry->set_text($proxy);	
	$database->preferences_proxy($proxy);
}	

sub save_preferences {
   my $self = shift;
   my $database = $self->{DATABASE};
   
   my $file_chooser = Gtk2::FileChooserDialog->new(
		'Save', undef, 'save',
		'gtk-ok' => 'ok',
		'gtk-cancel' => 'cancel',
	);
	
	my $filename;

	if('ok' eq $file_chooser->run) {
		$filename = $file_chooser->get_filename;
	}
	$file_chooser->destroy;

	if(defined $filename) {
		open(SAV, ">$filename") || print "Couldn't open $filename\n";
		
		print SAV "\# SEAT Preferences File\n\n";
		
      print SAV "\# How deep through the results returned by Search Engines would you like to go?\n";
      print SAV "\# Depth of 0 will allow SEAT to only analyse the first page returned. Depth\n";
      print SAV "\# 1 and more will make SEAT dig for more results.\n";
      			
		print SAV "\$depth=".$database->preferences_depth.";\n\n";
		
		print SAV "\# What would you like to do with mined results?\n";
      print SAV "\# 0 - don't do anything, just save them to database as usual\n";
      print SAV "\# 1 - save mined domains into the targets window to process later\n";
      print SAV "\# 2 - immediately request mined results with all current parameters\n";
                 
      print SAV "\$use_mined=".$database->preferences_mined.";\n\n";
      
      print SAV "\# How long to sleep between subsequent requests?\n";
      print SAV "\# Increase the number to avoid overloading your network and search engines\n";
      print SAV "\# Decrease the number to speed up the scanning process\n";
		
		print SAV "\$sleep=".$database->preferences_sleep.";\n\n";
		
		print SAV "\# How many simultaneous query threads?\n";
      print SAV "\# Decrease the number to avoid overloading your network and search engines\n";
      print SAV "\# Increase the number to speed up the scanning process\n";
		
		print SAV "\$nthreads=".$database->preferences_threads.";\n\n";
		
		print SAV "\# How do you want to identify yourself to search engines?\n";
      print SAV "\# Some search engines return different results for different User-Agents\n";
      print SAV "\# There are two special User-Agent names specific to SEAT:\n";
      print SAV "\# - Random Bot - every request is made using random bot identifier\n";
      print SAV "\# - Random Browser - every request is made using random browser name\n";
		
		print SAV "\$useragent=\"".$database->preferences_useragent."\";\n\n";
		
		print SAV "\# Do you want to send requests through a proxy server?\n";
      print SAV "\# To specify a proxy server use the following format:\n";
      print SAV "\#     ip_address_or_domain:port_number\n";
                 
      print SAV "\$proxy=\"".$database->preferences_proxy."\";\n\n";
		
		close SAV;
	}
}	

sub start {
   my $self = shift;
   my $database = $self->{DATABASE};
   my $worklog = $self->{WORKLOG};

   if(Worker->status != 1) {
      my $querygen = QueryGen->new($database,$worklog);
      Worker->do_job("querygen",$querygen);      
   }
   Worker->status(0);
}	

sub pause {
   my $self = shift;
   Worker->status(1);
}

sub stop {
   my $self = shift;   
   Worker->status(2);
}
1;
