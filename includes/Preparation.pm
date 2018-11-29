###############################################################################
# Package    : Preparation
# Description: Preparation page of SEAT. Allows a user to select targets as
#              well as signatures to test.
package Preparation;

use strict;
use warnings;

use Gtk2;
use Gtk2::SimpleList;
use Gtk2::Gdk::Keysyms;

use base 'Gtk2::VBox';
use Glib qw(TRUE FALSE);

use QueryParser;

###############################################################################
# Function   : new - instantiate new Preparation object
# Parameters : none
# Returns    : Preparation object
sub new {
	my ($class, $database, $tooltips, $help) = @_;
	
	my $self = Gtk2::VBox->new(FALSE,0);	
	
	# Entry boxes
	my $targets_entry;
	my $custom_query;

	############################################################################
	# Preparation Menubar
   my $menu_bar = Gtk2::MenuBar->new();

      ###############################################################################
      # Menu File
      my $menu_item_file = Gtk2::MenuItem->new('_File');
      my $file_menu = Gtk2::Menu->new();
      
      my $file_menu_targets_new = Gtk2::ImageMenuItem->new_with_label('New Targets List');
      $file_menu_targets_new->set_image(Gtk2::Image->new_from_stock('gtk-new','menu'));
      $file_menu_targets_new->signal_connect('activate' => sub {
         $self->new_target;
      });
      $file_menu->append($file_menu_targets_new);
      
      my $file_menu_targets_load = Gtk2::ImageMenuItem->new_with_label('Load Targets List');
      $file_menu_targets_load->set_image(Gtk2::Image->new_from_stock('gtk-open','menu'));
      $file_menu_targets_load->signal_connect('activate' => sub {
         $self->open_targets;
      });
      $file_menu->append($file_menu_targets_load);
      
      my $file_menu_targets_save = Gtk2::ImageMenuItem->new_with_label('Save Targets List');
      $file_menu_targets_save->set_image(Gtk2::Image->new_from_stock('gtk-save','menu'));
      $file_menu_targets_save->signal_connect('activate' => sub {
         $self->save_targets
      });
      $file_menu->append($file_menu_targets_save);
      
      # add a separator
      $file_menu->append(Gtk2::SeparatorMenuItem->new());
      
      my $file_menu_queries_new = Gtk2::ImageMenuItem->new_with_label('New Queries List');
      $file_menu_queries_new->set_image(Gtk2::Image->new_from_stock('gtk-new','menu'));
      $file_menu_queries_new->signal_connect('activate' => sub {
         $self->new_queries;
      });
      $file_menu->append($file_menu_queries_new);
      
      my $file_menu_queries_load = Gtk2::ImageMenuItem->new_with_label('Load Queries List');
      $file_menu_queries_load->set_image(Gtk2::Image->new_from_stock('gtk-open','menu'));
      $file_menu_queries_load->signal_connect('activate' => sub {
         $self->open_queries;
      });
      $file_menu->append($file_menu_queries_load);
      
      my $file_menu_queries_save = Gtk2::ImageMenuItem->new_with_label('Save Queries List');
      $file_menu_queries_save->set_image(Gtk2::Image->new_from_stock('gtk-save','menu'));
      $file_menu_queries_save->signal_connect('activate' => sub {
         $self->save_queries;
      });
      $file_menu->append($file_menu_queries_save);
          
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
      # Menu Targets
      my $menu_item_targets = Gtk2::MenuItem->new('_Targets');
      my $targets_menu = Gtk2::Menu->new();
      
      my $targets_menu_add = Gtk2::ImageMenuItem->new_with_label('Add Target');
      $targets_menu_add->set_image(Gtk2::Image->new_from_stock('gtk-add','menu'));
      $targets_menu_add->signal_connect('activate' => sub {
         $self->add_target($targets_entry->get_text);
      });
      $targets_menu->append($targets_menu_add);
      
      my $targets_menu_remove = Gtk2::ImageMenuItem->new_with_label('Remove Target');
      $targets_menu_remove->set_image(Gtk2::Image->new_from_stock('gtk-remove','menu'));
      $targets_menu_remove->signal_connect('activate' => sub {
         $self->remove_target;
      });
      $targets_menu->append($targets_menu_remove);
      
      # add a separator
      $targets_menu->append(Gtk2::SeparatorMenuItem->new());
      
      my $targets_menu_inverse = Gtk2::ImageMenuItem->new_with_label('Inverse');
      $targets_menu_inverse->set_image(Gtk2::Image->new_from_stock('gtk-justify-center','menu'));
      $targets_menu_inverse->signal_connect('activate' => sub {
         $self->inverse_target;
      });
      $targets_menu->append($targets_menu_inverse);
      
      my $targets_menu_selectall = Gtk2::ImageMenuItem->new_with_label('Select All');
      $targets_menu_selectall->set_image(Gtk2::Image->new_from_stock('gtk-justify-fill','menu'));
      $targets_menu_selectall->signal_connect('activate' => sub {
         $self->selectall_target;
      });
      $targets_menu->append($targets_menu_selectall);
      
      my $targets_menu_deselectall = Gtk2::ImageMenuItem->new_with_label('Deselect All');
      $targets_menu_deselectall->set_image(Gtk2::Image->new_from_stock('gtk-file','menu'));
      $targets_menu_deselectall->signal_connect('activate' => sub {
         $self->deselectall_target;
      });
      $targets_menu->append($targets_menu_deselectall);
   
      $menu_item_targets->set_submenu($targets_menu);
      $menu_bar->append($menu_item_targets);
   
      ###############################################################################
      # Menu Queries
      my $menu_item_queries = Gtk2::MenuItem->new('_Queries');
      my $queries_menu = Gtk2::Menu->new();
      
      my $queries_menu_add = Gtk2::ImageMenuItem->new_with_label('Add Query');
      $queries_menu_add->set_image(Gtk2::Image->new_from_stock('gtk-add','menu'));
      $queries_menu_add->signal_connect('activate' => sub {
         $self->add_query($custom_query->get_text);
      });
      $queries_menu->append($queries_menu_add);
                   
      my $queries_menu_remove = Gtk2::ImageMenuItem->new_with_label('Remove Query');
      $queries_menu_remove->set_image(Gtk2::Image->new_from_stock('gtk-remove','menu'));
      $queries_menu_remove->signal_connect('activate' => sub {
         $self->remove_query;
      });
      $queries_menu->append($queries_menu_remove);  
      
      my $queries_menu_edit = Gtk2::ImageMenuItem->new_with_label('Edit Query');
      $queries_menu_edit->set_image(Gtk2::Image->new_from_stock('gtk-edit','menu'));
      $queries_menu_edit->signal_connect('activate' => sub {
         $self->custom_query($custom_query->get_text);
      });
      $queries_menu->append($queries_menu_edit);
      
      # add a separator
      $queries_menu->append(Gtk2::SeparatorMenuItem->new());
      
      my $queries_menu_add_advanced = Gtk2::ImageMenuItem->new_with_label('Advanced Query');
      $queries_menu_add_advanced->set_image(Gtk2::Image->new_from_stock('gtk-bold','menu'));
      $queries_menu_add_advanced->signal_connect('activate' => sub {
         $self->custom_query;
      });
      $queries_menu->append($queries_menu_add_advanced); 
      
      # add a separator
      $queries_menu->append(Gtk2::SeparatorMenuItem->new());
      
      my $queries_menu_inverse = Gtk2::ImageMenuItem->new_with_label('Inverse');
      $queries_menu_inverse->set_image(Gtk2::Image->new_from_stock('gtk-justify-center','menu'));
      $queries_menu_inverse->signal_connect('activate' => sub {
         $self->inverse_query;
      });
      $queries_menu->append($queries_menu_inverse);
      
      my $queries_menu_selectall = Gtk2::ImageMenuItem->new_with_label('Select All');
      $queries_menu_selectall->set_image(Gtk2::Image->new_from_stock('gtk-justify-fill','menu'));
      $queries_menu_selectall->signal_connect('activate' => sub {
         $self->selectall_query;
      });
      $queries_menu->append($queries_menu_selectall);
      
      my $queries_menu_deselectall = Gtk2::ImageMenuItem->new_with_label('Deselect All');
      $queries_menu_deselectall->set_image(Gtk2::Image->new_from_stock('gtk-file','menu'));
      $queries_menu_deselectall->signal_connect('activate' => sub {
         $self->deselectall_query;
      });
      $queries_menu->append($queries_menu_deselectall);
   
      $menu_item_queries->set_submenu($queries_menu);
      $menu_bar->append($menu_item_queries);
      
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
   
	
	my $preparation = Gtk2::HPaned->new;

	############################################################################
	# Targets
	my $targets = Gtk2::VBox->new(FALSE,0);
	$targets->set_size_request('170',);
	my $targets_list;
	
	############################################################################
	# Targets Toolbar
	my $targets_toolbar = Gtk2::Toolbar->new();
	$targets_toolbar->set_icon_size('menu');
	$targets_toolbar->set_style('icons');
	$targets_toolbar->set_tooltips(TRUE);

      #########################################################################
		# Add Target
		my $targets_add = Gtk2::ToolButton->new_from_stock('gtk-add');
	   $targets_add->signal_connect('clicked' => sub {
         $self->add_target($targets_entry->get_text);
		});
		$targets_add->set_tooltip($tooltips,"Add a new target","");
		$targets_toolbar->insert($targets_add,-1);

      #########################################################################
		# Remove Target
		my $targets_remove = Gtk2::ToolButton->new_from_stock('gtk-remove');
		$targets_remove->signal_connect('clicked' => sub {
		   $self->remove_target;
		});
		$targets_remove->set_tooltip($tooltips,"Remove selected target","");
		$targets_toolbar->insert($targets_remove,-1);
		
		#########################################################################
		# New Target List
		my $targets_new = Gtk2::ToolButton->new_from_stock('gtk-new');
		$targets_new->signal_connect('clicked' => sub {
		   $self->new_target;
		});
		$targets_new->set_tooltip($tooltips,"Create a new target list","");
		$targets_toolbar->insert($targets_new,-1);

      #########################################################################
		# Open Target List
		my $targets_open = Gtk2::ToolButton->new_from_stock('gtk-open');
		$targets_open->signal_connect('clicked' => sub {
		   $self->open_targets;
		});
		$targets_open->set_tooltip($tooltips,"Load targets list from a file","");
		$targets_toolbar->insert($targets_open,-1);

      #########################################################################
		# Save Target List
		my $targets_save = Gtk2::ToolButton->new_from_stock('gtk-save');
		$targets_save->signal_connect('clicked' => sub {
		   $self->save_targets;
		});
		$targets_save->set_tooltip($tooltips,"Save targets list to a file","");
		$targets_toolbar->insert($targets_save,-1);

      #########################################################################
		# Inverse Target List
		my $targets_inverse = Gtk2::ToolButton->new_from_stock('gtk-justify-fill');
		$targets_inverse->signal_connect('clicked' => sub {
		   $self->inverse_target;
		});
		$targets_inverse->set_tooltip($tooltips,"Inverse targets list selection","");
		$targets_toolbar->insert($targets_inverse,-1);

	$targets->pack_start($targets_toolbar,FALSE,FALSE,0);

	$targets_entry = Gtk2::Entry->new();
	$targets_entry->signal_connect('key_press_event' => sub {
	   my($widget, $event) = @_;
	   if($event->keyval == $Gtk2::Gdk::Keysyms{KP_Enter} || $event->keyval == $Gtk2::Gdk::Keysyms{Return}) {	   
         $self->add_target($targets_entry->get_text);
	   }	   
	});
	
	$targets->pack_start($targets_entry,FALSE,FALSE,0);

	
	############################################################################
	# Targets Frame
	my $targets_frame = Gtk2::Frame->new();

		# Targets Scrolled Window
		my $targets_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$targets_sw->set_policy('automatic','automatic');

      # Targets Simple List
		$targets_list = Gtk2::SimpleList->new (
			"" => 'bool',
			"Targets" => 'text',
		);
		
		# Enable searching
		$targets_list->set_search_column(1);
		
		# Enable sorting
		my $targets_column = $targets_list->get_column (1);
		$targets_column->set_sort_column_id(1);
		
		# Connect signal to checkbox
		my $targets_cell = ($targets_list->get_column (0)->get_cell_renderers)[0];
		$targets_cell->signal_connect (toggled => sub {
   		my ($cell, $text_path) = @_;
	   	my $active = ($targets_cell->get_active ? 0 : 1);
	   	my $name = @{$targets_list->{data}}[$text_path]->[1];
	   	$database->target($name,$active);
	  	});	
	  	
	  	# Connect signal to delete key
	  	$targets_list->signal_connect(key_press_event => sub {	   
	  	   my($widget, $event) = @_;
	      if($event->keyval == $Gtk2::Gdk::Keysyms{Delete} || $event->keyval == $Gtk2::Gdk::Keysyms{BackSpace} || $event->keyval == $Gtk2::Gdk::Keysyms{KP_Delete}) {
            $self->remove_target;
	      }	   
	  	});
	  	
	  	# Connect signal to selection
		$targets_list->get_selection->signal_connect (changed => sub {
		   my ($selection) = @_;
		   my ($model,$iter) = $selection->get_selected;
		   if($iter) { 
		   my $name = $model->get($iter, 1);
		   $targets_entry->set_text($name);
		   }
		});
		
		
		$targets_sw->add($targets_list);
		$targets_frame->add($targets_sw);	
	
	$targets->pack_start($targets_frame,TRUE,TRUE,0);
	$preparation->add1($targets);

	############################################################################
   # Queries
   my $queries = Gtk2::VBox->new(FALSE,0);
	my $queries_list;
	my $description_buffer;
	
	############################################################################
	# Queries Toolbar
	my $queries_toolbar = Gtk2::Toolbar->new();
	$queries_toolbar->set_icon_size('menu');
	$queries_toolbar->set_style('icons');

      #########################################################################
		# Add Queries
		my $queries_add = Gtk2::ToolButton->new_from_stock('gtk-add');
	   $queries_add->signal_connect('clicked' => sub {	      
         $self->add_query($custom_query->get_text);
		});
		$queries_add->set_tooltip($tooltips,"Add a new query","");
		$queries_toolbar->insert($queries_add,-1);

      #########################################################################
		# Remove Queries
		my $queries_remove = Gtk2::ToolButton->new_from_stock('gtk-remove');
		$queries_remove->signal_connect('clicked' => sub {   
		   $self->remove_query;
		});
		$queries_remove->set_tooltip($tooltips,"Remove selected query","");
		$queries_toolbar->insert($queries_remove,-1);
		
		#########################################################################
		# Edit Query
		my $queries_edit = Gtk2::ToolButton->new_from_stock('gtk-edit');
		$queries_edit->signal_connect('clicked' => sub {		
         $self->custom_query($custom_query->get_text);
		});
		$queries_edit->set_tooltip($tooltips,"Edit selected query","");
		$queries_toolbar->insert($queries_edit,-1);
		
		#########################################################################
		# New Queries List
		my $queries_new = Gtk2::ToolButton->new_from_stock('gtk-new');
		$queries_new->signal_connect('clicked' => sub {
         $self->new_queries;
		});
		$queries_new->set_tooltip($tooltips,"Create a new queries list","");
		$queries_toolbar->insert($queries_new,-1);

      #########################################################################
		# Open Queries List
		my $queries_open = Gtk2::ToolButton->new_from_stock('gtk-open');
		$queries_open->signal_connect('clicked' => sub {
		   $self->open_queries
		});
		$queries_open->set_tooltip($tooltips,"Load queries list from a file","");
		$queries_toolbar->insert($queries_open,-1);

      #########################################################################
		# Save Queries List 
		my $queries_save = Gtk2::ToolButton->new_from_stock('gtk-save');
		$queries_save->signal_connect('clicked' => sub {
		   $self->save_queries;
		});
		$queries_save->set_tooltip($tooltips,"Save queries list to a file","");
		$queries_toolbar->insert($queries_save,-1);

      #########################################################################
		# Inverse Queries List
		my $queries_inverse = Gtk2::ToolButton->new_from_stock('gtk-justify-fill');
		$queries_inverse->signal_connect('clicked' => sub {
		   $self->inverse_query;
		});
		$queries_inverse->set_tooltip($tooltips,"Inverse queries list selection","");
		$queries_toolbar->insert($queries_inverse,-1);

	$queries->pack_start($queries_toolbar,FALSE,FALSE,0);

	############################################################################
	# Custom Query	
	my $custom_hbox = Gtk2::HBox->new(FALSE,0);
	$custom_query = Gtk2::Entry->new;
	$custom_query->signal_connect('key_press_event' => sub {
	   my($widget, $event) = @_;
	   if($event->keyval == $Gtk2::Gdk::Keysyms{KP_Enter} || $event->keyval == $Gtk2::Gdk::Keysyms{Return}) {	   
         my $newquery = $custom_query->get_text;
			if($newquery) {
				unless($database->query_exists($newquery)) {
				   push @{$queries_list->{data}}, [TRUE, $newquery];
				}
				$database->query($newquery,1,"CUSTOM");
			}
	   }	   
	});
	$custom_hbox->pack_start($custom_query,TRUE,TRUE,0);
	
	my $custom_button = Gtk2::Button->new;
	$custom_button->set_image(Gtk2::Image->new_from_stock('gtk-bold','menu'));	
	$custom_button->set_size_request('30','27');
	$custom_button->signal_connect('clicked' => sub {
			$self->custom_query;
		});		
   $tooltips->set_tip($custom_button,"Add Custom Query");
	$custom_hbox->pack_start($custom_button,FALSE,FALSE,0);

	$queries->pack_start($custom_hbox,FALSE,FALSE,0);

	############################################################################
	# Queries Frame
	my $queries_frame = Gtk2::Frame->new();

		# Queries Scrolled Window
		my $queries_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$queries_sw->set_policy('automatic','automatic');

      # Queries Simple List
		$queries_list = Gtk2::SimpleList->new (
			"" => 'bool',
			"Queries" => 'text',
		);
		
		# Enable searching
		$queries_list->set_search_column(1);
		
		# Enable sorting
		my $queries_column = $queries_list->get_column (1);
		$queries_column->set_sort_column_id(1);
		
		# Connect signal to delete key
		$queries_list->signal_connect(key_press_event => sub {	   
	  	   my($widget, $event) = @_;
	      if($event->keyval == $Gtk2::Gdk::Keysyms{Delete} || $event->keyval == $Gtk2::Gdk::Keysyms{BackSpace} || $event->keyval == $Gtk2::Gdk::Keysyms{KP_Delete}) {
            $self->remove_query;
	      }	   
	  	});
		
		# Connect signal to checkbox 
		my $queries_cell = ($queries_list->get_column (0)->get_cell_renderers)[0];
		$queries_cell->signal_connect (toggled => sub {
		   my ($cell, $text_path) = @_;
		   my $active = ($queries_cell->get_active ? 0 : 1);
		   my $name = @{$queries_list->{data}}[$text_path]->[1];
		   $database->query($name,$active);
		});	
		
		# Connect signal to selection
		$queries_list->get_selection->signal_connect (changed => sub {
		   my ($selection) = @_;
		   my ($model,$iter) = $selection->get_selected;
		   if($iter) { 
		   my $name = $model->get($iter, 1);
		   my $query = $database->query($name);
		   $description_buffer->set_text(@$query[1]);
		   $custom_query->set_text($name);
		   }
		});
		
		$queries_sw->add($queries_list);
		$queries_frame->add($queries_sw);		

	$queries->pack_start($queries_frame,TRUE,TRUE,0);

	############################################################################
	# Description Frame
	my $description = Gtk2::Frame->new("Description");
	$description->set_size_request(0,200);

	my $description_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$description_sw->set_policy("never","automatic");

	   my $description_textview = Gtk2::TextView->new();
	   $description_textview->set_editable(FALSE);
	   $description_textview->set_cursor_visible(FALSE);
	   $description_textview->set_wrap_mode("word");
   
	   $description_buffer = $description_textview->get_buffer();

	$description_sw->add($description_textview);
	$description->add($description_sw);
	
	$queries->pack_start($description,FALSE,TRUE,0);

	$preparation->add2($queries);

	$self->pack_start($preparation,TRUE,TRUE,0);	
	

	############################################################################
	# Initialize common variables
	$self->{DATABASE} = $database;
	$self->{TARGETS}  = $targets_list;
	$self->{QUERIES}  = $queries_list;
		
	############################################################################
	# Instantiate object	
	bless $self, $class;
	return $self;
}

###############################################################################
# Function  : add_target - used to add targets to targets list and database
# Parameters: target name
# Returns   : none
sub add_target {
   my ($self,$newtarget) = @_;
   my $database = $self->{DATABASE};
   my $targets_list = $self->{TARGETS};
   
  	if($newtarget) {
	   # check if target is an ip address or ip address range
	   if($newtarget =~ /(\d+|\*)\.(\d+|\*)\.(\d+|\*)\.(\d+|\*)/) {
	      my @targetlist = &ip_range($newtarget);
	      foreach (@targetlist) {
 				unless ($database->target_exists($_)) { 
      		   push @{$targets_list->{data}}, [TRUE, $_];
 		      		$database->target($_,TRUE);
      		}
	      }
	   } else {    
  			unless ($database->target_exists($newtarget)) { 
  			   push @{$targets_list->{data}}, [TRUE, $newtarget];
  			}
 			$database->target($newtarget,TRUE);
  		}
	}
}

###############################################################################
# Function  : remove_target - used to remove targets from targets list and database
# Parameters: none
# Returns   : none
sub remove_target {
   my $self = shift;
   
   my $targets_list = $self->{TARGETS};
   my $database = $self->{DATABASE};
   
	my @selected = $targets_list->get_selected_indices;
	foreach my $index (@selected) {
	   $database->target_remove(@{$targets_list->{data}}[$index]->[1]);
		splice @{$targets_list->{data}}, $index, 1;
	}
}

###############################################################################
# Function  : new_target - create new target list
# Parameters: none
# Returns   : none
sub new_target {
   my $self = shift;
   my $database = $self->{DATABASE};
   my $targets_list = $self->{TARGETS};
	@{$targets_list->{data}} = ();
	$database->target_purge;
}

###############################################################################
# Function  : open_targets - loads target list from a user specified file
# Parameters: none
# Returns   : targets list
sub open_targets {
   my $self = shift;
   my $database = $self->{DATABASE};
   my $targets_list = $self->{TARGETS};
   
	my $file_chooser = Gtk2::FileChooserDialog->new(
		'Open', undef, 'open',
		'gtk-ok' => 'ok',
		'gtk-cancel' => 'cancel',
	);

	my $filename;

	if('ok' eq $file_chooser->run) {
		$filename = $file_chooser->get_filename;
	}
	$file_chooser->destroy;

	my @targets;

	if((defined $filename) && (-f $filename)) {
		open(DAT, $filename);
		while (<DAT>) {
			chomp;
			push @targets, $_;
		}		
		close(DAT);
	}
	
	foreach my $newtarget (@targets) {
		unless ($database->target_exists($newtarget)) { 
	      push @{$targets_list->{data}}, [TRUE, $newtarget];
		}
	   $database->target($newtarget,TRUE);
	}
			
}

###############################################################################
# Function   : save_targets - saves target list to a user specified file
# Parameters : targets list
# Returns    : none
sub save_targets {
   my $self = shift;
   
   my $database = $self->{DATABASE};
   my $targets = $database->targets;
	
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
		foreach (keys %$targets) {
			print SAV "$_\n";
		}
		close SAV;
	}
}

sub inverse_target {
   my $self = shift;
   
   my $targets_list = $self->{TARGETS};
   my $database = $self->{DATABASE};
   
	foreach (@{$targets_list->{data}}) {
		$_->[0] = !$_->[0];
		$database->target($_->[1],$_->[0]);
	}
}

sub selectall_target {
   my $self = shift;
   
   my $targets_list = $self->{TARGETS};
   my $database = $self->{DATABASE};
   
	foreach (@{$targets_list->{data}}) {
		$_->[0] = 1;
		$database->target($_->[1],$_->[0]);
	}
}

sub deselectall_target {
   my $self = shift;
   
   my $targets_list = $self->{TARGETS};
   my $database = $self->{DATABASE};
   
	foreach (@{$targets_list->{data}}) {
		$_->[0] = 0;
		$database->target($_->[1],$_->[0]);
	}
}

sub add_query {
   my ($self,$newquery) = @_;
   
   my $queries_list = $self->{QUERIES};
   my $database = $self->{DATABASE};

	if($newquery) {
		unless($database->query_exists($newquery)) {
		   push @{$queries_list->{data}}, [TRUE, $newquery];
		}
   	$database->query($newquery,1,"CUSTOM");
   }
}

###############################################################################
# Function   : remove_query - removes query from queries list and database
# Parameters : none
# Returns    : none
sub remove_query {
   my $self = shift;
   
   my $queries_list = $self->{QUERIES};
   my $database = $self->{DATABASE};
   
	my @selected = $queries_list->get_selected_indices;
	foreach my $index (@selected) {
	   $database->query_remove(@{$queries_list->{data}}[$index]->[1]);
		splice @{$queries_list->{data}}, $index, 1;
	}
}

###############################################################################
# Function   : new_queries - create new queries list
# Parameters : none
# Returns    : none
sub new_queries {
   my $self = shift;
   my $queries_list = $self->{QUERIES};
   my $database = $self->{DATABASE};

	@{$queries_list->{data}} = ();
	$database->query_purge;
}
###############################################################################
# Function   : open_queries - loads queries from signature database
# Parameters : none
# Returns    : queries and description hash
sub open_queries {
   my $self = shift;
   my $queries_list = $self->{QUERIES};
   my $database = $self->{DATABASE};
   
	my $file_chooser = Gtk2::FileChooserDialog->new(
		'Open', undef, 'open',
		'gtk-ok' => 'ok',
		'gtk-cancel' => 'cancel',
	);
	
	# Create file extention filters for various supported signature dbs
	my $all_filter = Gtk2::FileFilter->new;
	$all_filter->set_name("All Databases");
	$all_filter->add_pattern("*");
	$file_chooser->add_filter($all_filter);
	
	my $ghdb_filter = Gtk2::FileFilter->new;
	$ghdb_filter->set_name("GHDB");
	$ghdb_filter->add_pattern("*.xml");
	$file_chooser->add_filter($ghdb_filter);
	
	my $gs_filter = Gtk2::FileFilter->new;
	$gs_filter->set_name("GoogleScan");
	$gs_filter->add_pattern("*.gs");
	$file_chooser->add_filter($gs_filter);
	
	my $nikto_filter = Gtk2::FileFilter->new;
	$nikto_filter->set_name("Nikto");
	$nikto_filter->add_pattern("*.nikto");
	$file_chooser->add_filter($nikto_filter);
	
	my $urlchk_filter = Gtk2::FileFilter->new;
	$urlchk_filter->set_name("URLCHK");
	$urlchk_filter->add_pattern("*.urlchk");
	$file_chooser->add_filter($urlchk_filter);
	
	my $wmap_filter = Gtk2::FileFilter->new;
	$wmap_filter->set_name("Wmap");
	$wmap_filter->add_pattern("*.wmap");
	$file_chooser->add_filter($wmap_filter);
	
	my $nestea_filter = Gtk2::FileFilter->new;
	$nestea_filter->set_name("Nestea");
	$nestea_filter->add_pattern("*.nestea");
	$file_chooser->add_filter($nestea_filter);
	
	my $filename;

	if('ok' eq $file_chooser->run) {
		$filename = $file_chooser->get_filename;
	}
	
	$file_chooser->destroy;
	
	my %queries;

	if((defined $filename) && (-f $filename)) {
	   %queries = QueryParser->parse($filename);
	}
	
	foreach my $newquery (keys %queries) {
		unless($database->query_exists($newquery)) {
	      push @{$queries_list->{data}}, [TRUE, $newquery];
	   	$database->query($newquery,1,$queries{$newquery});
	   }
	}
}

###############################################################################
# Function   : save_queries - saves queries to a user specified file
# Parameters : queries list
# Returns    : none
sub save_queries {
	my $self = shift;
	
	my $database = $self->{DATABASE};
	my $queries = $database->queries;
	
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
		foreach my $name (keys %$queries) {
		   print SAV "<signature>\n";
			print SAV " <querystring>$name</querystring>\n";
		   my $query = $$queries{$name};
		   print SAV " <textualDescription>".@$query[1]."</textualDescription>\n";
		   print SAV "</signature>\n";
		}
		print SAV "</searchEngineSignature>\n";
		close SAV;
	}
}


sub inverse_query {
   my $self = shift;
   
   my $queries_list = $self->{QUERIES};
   my $database = $self->{DATABASE};
   
	foreach (@{$queries_list->{data}}) {
		$_->[0] = !$_->[0];
		$database->query($_->[1],$_->[0]);
	}
}

sub selectall_query {
   my $self = shift;
   
   my $queries_list = $self->{QUERIES};
   my $database = $self->{DATABASE};
   
	foreach (@{$queries_list->{data}}) {
		$_->[0] = 1;
		$database->query($_->[1],$_->[0]);
	}
}

sub deselectall_query {
   my $self = shift;
   
   my $queries_list = $self->{QUERIES};
   my $database = $self->{DATABASE};
   
	foreach (@{$queries_list->{data}}) {
		$_->[0] = 0;
		$database->query($_->[1],$_->[0]);
	}
}

###############################################################################
# Function   : custom_query - helps user generate a more advanced query
# Parameters : query name
# Returns    : none
sub custom_query {
	my ($self, $query_name) = @_;
	my $queries_list = $self->{QUERIES};
	my $database = $self->{DATABASE};
	
	my $parent = $self->get_parent->get_parent->get_parent;
	
	my $dialog = Gtk2::Dialog->new("SEAT: Advanced Query",$parent,'destroy-with-parent',
											 'gtk-add'   => 'accept',
											 'gtk-cancel' => 'cancel');

   ############################################################################
   # First get user input
	my $table = Gtk2::Table->new(5,2,FALSE);

	# Raw Query
	my $raw_label = Gtk2::Label->new("Raw Query:");
	$raw_label->set_alignment(1,.5);
	$table->attach_defaults($raw_label,0,1,0,1);
	my $raw = Gtk2::Entry->new;
	$table->attach_defaults($raw,1,2,0,1);

	# In Title Query
	my $intitle_label = Gtk2::Label->new("In Title:");
	$intitle_label->set_alignment(1,.5);
	$table->attach_defaults($intitle_label,0,1,1,2);
	my $intitle = Gtk2::Entry->new;
	$table->attach_defaults($intitle,1,2,1,2);

	# In URL Query
	my $inurl_label = Gtk2::Label->new("In URL:");
	$inurl_label->set_alignment(1,.5);
	$table->attach_defaults($inurl_label,0,1,2,3);
	my $inurl = Gtk2::Entry->new;
	$table->attach_defaults($inurl,1,2,2,3);
	
	# Filetype Query
	my $filetype_label = Gtk2::Label->new("Filetype:");
	$filetype_label->set_alignment(1,.5);
	$table->attach_defaults($filetype_label,0,1,3,4);
	my $filetype = Gtk2::Entry->new;
	$table->attach_defaults($filetype,1,2,3,4);

	# Description
	my $description_label = Gtk2::Label->new("Description:");
	$description_label->set_alignment(1,0);
	$table->attach_defaults($description_label,0,1,4,5);
	my $description_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$description_sw->set_policy("never","automatic");
		$description_sw->set_shadow_type("out");
	   $description_sw->set_size_request('300','100');

		# Description Text View Window
		my $description_textview = Gtk2::TextView->new();
		$description_textview->set_cursor_visible(TRUE);
		$description_textview->set_wrap_mode("word");

		my $description_buffer = $description_textview->get_buffer();

	$description_sw->add($description_textview);
	$table->attach_defaults($description_sw,1,2,4,5);
	
	############################################################################
	# Second load Variables for predefined Search Engines
	if(defined $query_name) {	   	   
	   $raw->set_text($query_name);
		my $query = $database->query($query_name);
		$description_buffer->set_text(@$query[1]);	
	}

	$dialog->vbox->add($table);
	$dialog->show_all;
	
	############################################################################
	# Third add new/modified query into the database	
	my $query;
		
	$dialog->signal_connect(response => sub {
		if($_[1] =~ m/accept/){
			if($raw->get_text) { $query = $raw->get_text }
			if($intitle->get_text) {$query .= " intitle:".$intitle->get_text }
			if($inurl->get_text) {$query .= " inurl:".$inurl->get_text }
			if($filetype->get_text) {$query .= " filetype:".$filetype->get_text }
			if($query) { 
   			$query =~ s/^\s+//;
				my ($start,$end) = $description_buffer->get_bounds;
				$database->query($query,1,$description_buffer->get_text($start,$end,TRUE));
				foreach (@{$queries_list->{data}}) { if(@$_[1] eq $query) { return } }		
				push @{$queries_list->{data}}, [TRUE, $query];
			}
			$query = "";
		}
		else {
			$dialog->destroy;
		}
	});
}

###############################################################################
# Function   : ip_range - generates a range of ip addresses
# Parameters : ip address with wildcard(s)
# Returns    : ip address list
sub ip_range {
	my $ip_entry = shift;
	my @ips;
	my ($a,$b,$c,$d) = split(/\./, $ip_entry);
	my ($one, $two, $three, $four);
	
	# Generate ranges of IP Address
	for(my $A = 1; $A < 256; $A++) {
		for(my $B = 1; $B < 256; $B++) {
			for(my $C = 1; $C < 256; $C++) {
				for(my $D = 1; $D < 256; $D++) {
					if($a eq "*") { $one = $A } else { $one = $a; $A = 256; }
					if($b eq "*") { $two = $B } else { $two = $b; $B = 256; }
					if($c eq "*") { $three = $C } else { $three = $c; $C = 256; }
					if($d eq "*") { $four = $D } else { $four = $d; $D = 256; }
		
					push @ips, "$one.$two.$three.$four";
				}
			}
		}
	}
	return @ips;
}
1;
