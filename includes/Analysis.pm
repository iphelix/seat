###############################################################################
# Package    : Analysis
# Description: Analysis page of SEAT. Allows a user to analyze collected results
#              by offering a simplified access to the database to pick exactly
#              which information is displayed on the screen
package Analysis;

use strict;
use warnings;

use Gtk2;
use base 'Gtk2::VBox';
use Glib qw(TRUE FALSE);

use ReportGen;

###############################################################################
# Function   : new - instantiate new Analysis object
# Parameters : none
# Returns    : Analysis object
sub new {
	my ($class, $database, $tooltips, $help, $preparation) = @_;	
	
	my $self = Gtk2::VBox->new(FALSE,0);	
	
	############################################################################
	# Analysi Menubar
   my $menu_bar = Gtk2::MenuBar->new();

      ###############################################################################
      # Menu File
      my $menu_item_file = Gtk2::MenuItem->new('_File');
      my $file_menu = Gtk2::Menu->new();
      
      my $file_menu_results_new = Gtk2::ImageMenuItem->new_with_label('New Results Database');
      $file_menu_results_new->set_image(Gtk2::Image->new_from_stock('gtk-new','menu'));
      $file_menu_results_new->signal_connect('activate' => sub {
         $self->new_results;
      });
      $file_menu->append($file_menu_results_new);
      
      my $file_menu_results_save = Gtk2::ImageMenuItem->new_with_label('Save Results Database');
      $file_menu_results_save->set_image(Gtk2::Image->new_from_stock('gtk-save','menu'));
      $file_menu_results_save->signal_connect('activate' => sub {
         $self->save_results;
      });
      $file_menu->append($file_menu_results_save);
      
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
         $self->inverse('TARGETS');
      });
      $targets_menu->append($targets_menu_inverse);
      
      my $targets_menu_selectall = Gtk2::ImageMenuItem->new_with_label('Select All');
      $targets_menu_selectall->set_image(Gtk2::Image->new_from_stock('gtk-justify-fill','menu'));
      $targets_menu_selectall->signal_connect('activate' => sub {
         $self->selectall('TARGETS');
      });
      $targets_menu->append($targets_menu_selectall);
      
      my $targets_menu_deselectall = Gtk2::ImageMenuItem->new_with_label('Deselect All');
      $targets_menu_deselectall->set_image(Gtk2::Image->new_from_stock('gtk-file','menu'));
      $targets_menu_deselectall->signal_connect('activate' => sub {
         $self->deselectall('TARGETS');
      });
      $targets_menu->append($targets_menu_deselectall);
         
      $menu_item_targets->set_submenu($targets_menu);
      $menu_bar->append($menu_item_targets);
      
      ###############################################################################
      # Menu Queries
      my $menu_item_queries = Gtk2::MenuItem->new('_Queries');
      my $queries_menu = Gtk2::Menu->new();
      
      my $queries_menu_inverse = Gtk2::ImageMenuItem->new_with_label('Inverse');
      $queries_menu_inverse->set_image(Gtk2::Image->new_from_stock('gtk-justify-center','menu'));
      $queries_menu_inverse->signal_connect('activate' => sub {
         $self->inverse('QUERIES');
      });
      $queries_menu->append($queries_menu_inverse);
      
      my $queries_menu_selectall = Gtk2::ImageMenuItem->new_with_label('Select All');
      $queries_menu_selectall->set_image(Gtk2::Image->new_from_stock('gtk-justify-fill','menu'));
      $queries_menu_selectall->signal_connect('activate' => sub {
         $self->selectall('QUERIES');
      });
      $queries_menu->append($queries_menu_selectall);
      
      my $queries_menu_deselectall = Gtk2::ImageMenuItem->new_with_label('Deselect All');
      $queries_menu_deselectall->set_image(Gtk2::Image->new_from_stock('gtk-file','menu'));
      $queries_menu_deselectall->signal_connect('activate' => sub {
         $self->deselectall('QUERIES');
      });
      $queries_menu->append($queries_menu_deselectall);
   
      $menu_item_queries->set_submenu($queries_menu);
      $menu_bar->append($menu_item_queries);
      
      ###############################################################################
      # Menu Search Engines
      my $menu_item_searchengines = Gtk2::MenuItem->new('_Search Engines');
      my $searchengines_menu = Gtk2::Menu->new();
            
      my $searchengines_menu_inverse = Gtk2::ImageMenuItem->new_with_label('Inverse');
      $searchengines_menu_inverse->set_image(Gtk2::Image->new_from_stock('gtk-justify-center','menu'));
      $searchengines_menu_inverse->signal_connect('activate' => sub {
         $self->inverse('SEARCHENGINES');
      });
      $searchengines_menu->append($searchengines_menu_inverse);
      
      my $searchengines_menu_selectall = Gtk2::ImageMenuItem->new_with_label('Select All');
      $searchengines_menu_selectall->set_image(Gtk2::Image->new_from_stock('gtk-justify-fill','menu'));
      $searchengines_menu_selectall->signal_connect('activate' => sub {
         $self->selectall('SEARCHENGINES');
      });
      $searchengines_menu->append($searchengines_menu_selectall);
      
      my $searchengines_menu_deselectall = Gtk2::ImageMenuItem->new_with_label('Deselect All');
      $searchengines_menu_deselectall->set_image(Gtk2::Image->new_from_stock('gtk-file','menu'));
      $searchengines_menu_deselectall->signal_connect('activate' => sub {
         $self->deselectall('SEARCHENGINES');
      });
      $searchengines_menu->append($searchengines_menu_deselectall);
   
      $menu_item_searchengines->set_submenu($searchengines_menu);
      $menu_bar->append($menu_item_searchengines);       
            
      
      ###############################################################################
      # Menu Mined
      my $menu_item_mined = Gtk2::MenuItem->new('_Mined');
      my $mined_menu = Gtk2::Menu->new();
      
      my $mined_menu_recycle = Gtk2::ImageMenuItem->new_with_label('Recycle Mined');
      $mined_menu_recycle->set_image(Gtk2::Image->new_from_stock('gtk-refresh','menu'));
      $mined_menu_recycle->signal_connect('activate' => sub {
         $self->recycle_mined;
      });
      $mined_menu->append($mined_menu_recycle);
      
      # add a separator
      $mined_menu->append(Gtk2::SeparatorMenuItem->new());
                  
      my $mined_menu_inverse = Gtk2::ImageMenuItem->new_with_label('Inverse');
      $mined_menu_inverse->set_image(Gtk2::Image->new_from_stock('gtk-justify-center','menu'));
      $mined_menu_inverse->signal_connect('activate' => sub {
         $self->inverse('MINED');
      });
      $mined_menu->append($mined_menu_inverse);
      
      my $mined_menu_selectall = Gtk2::ImageMenuItem->new_with_label('Select All');
      $mined_menu_selectall->set_image(Gtk2::Image->new_from_stock('gtk-justify-fill','menu'));
      $mined_menu_selectall->signal_connect('activate' => sub {
         $self->selectall('MINED');
      });
      $mined_menu->append($mined_menu_selectall);
      
      my $mined_menu_deselectall = Gtk2::ImageMenuItem->new_with_label('Deselect All');
      $mined_menu_deselectall->set_image(Gtk2::Image->new_from_stock('gtk-file','menu'));
      $mined_menu_deselectall->signal_connect('activate' => sub {
         $self->deselectall('MINED');
      });
      $mined_menu->append($mined_menu_deselectall);
   
      $menu_item_mined->set_submenu($mined_menu);
      $menu_bar->append($menu_item_mined);  
      
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
	
	my $results = Gtk2::VPaned->new;
	
	############################################################################
	# Results Selection		
	my $results_selection = Gtk2::HBox->new(FALSE,0);
	
	my $targets_list;
	my $queries_list;
	my $searchengines_list;
	
	############################################################################
	# Targets
	my $targets = Gtk2::VBox->new(FALSE,0);
		
	############################################################################	
	# Targets Toolbar
	my $targets_toolbar = Gtk2::Toolbar->new();
	$targets_toolbar->set_icon_size('menu');
	$targets_toolbar->set_style('icons');
	$targets_toolbar->set_tooltips(TRUE);

   ############################################################################
	# Remove Target
	my $targets_remove = Gtk2::ToolButton->new_from_stock('gtk-remove');
	$targets_remove->signal_connect('clicked' => sub {
      $self->remove_target;
	});
	$targets_remove->set_tooltip($tooltips,"Remove selected target","");
	$targets_toolbar->insert($targets_remove,-1);
	
	############################################################################
	# New Targets List
	my $targets_new = Gtk2::ToolButton->new_from_stock('gtk-new');
	$targets_new->signal_connect('clicked' => sub {	
      $self->new_results;
	});
	$targets_new->set_tooltip($tooltips,"Clear all targets","");
	$targets_toolbar->insert($targets_new,-1);
	
	############################################################################
	# Save Targets List
	my $targets_save = Gtk2::ToolButton->new_from_stock('gtk-save');
	$targets_save->signal_connect('clicked' => sub {
	   $self->save_results;
	});
	$targets_save->set_tooltip($tooltips,"Save results to a file","");
	$targets_toolbar->insert($targets_save,-1);
	
	############################################################################
	# Reverse Targets List
	my $targets_reverse = Gtk2::ToolButton->new_from_stock('gtk-justify-fill');
	$targets_reverse->signal_connect('clicked' => sub {		
      $self->inverse('TARGETS');
	});
	$targets_reverse->set_tooltip($tooltips,"Reverse targets selection","");
	$targets_toolbar->insert($targets_reverse,-1);
		
	$targets->pack_start($targets_toolbar,FALSE,FALSE,0);
	
	
	############################################################################
	# Targets Frame
	my $targets_frame = Gtk2::Frame->new();
	   $targets_frame->set_size_request('170',);
	   
   # Targets Scrolled Window
	my $targets_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$targets_sw->set_policy('automatic','automatic');

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
		   $self->display_results;
	  	});	
	  	
	  	# Connect signal to selection
		$targets_list->get_selection->signal_connect (changed => sub {
		   my ($selection) = @_;
		   my ($model,$iter) = $selection->get_selected;
		   if($iter) { 
		   my $name = $model->get($iter, 1);
		   }
		});
		
		$targets_sw->add($targets_list);
		$targets_frame->add($targets_sw);
		
		$targets->pack_start($targets_frame,TRUE,TRUE,0);
		
	$results_selection->pack_start($targets,FALSE,TRUE,0);
	
	############################################################################
	# Queries
	my $queries = Gtk2::VBox->new(FALSE,0);
	
	############################################################################	
	# Queries Toolbar
	my $queries_toolbar = Gtk2::Toolbar->new();
	$queries_toolbar->set_icon_size('menu');
	$queries_toolbar->set_style('icons');
	$queries_toolbar->set_tooltips(TRUE);
	
	############################################################################
	# Reverse Queries List
	my $queries_reverse = Gtk2::ToolButton->new_from_stock('gtk-justify-fill');
	$queries_reverse->signal_connect('clicked' => sub {		
      $self->inverse('QUERIES');
	});
	$queries_reverse->set_tooltip($tooltips,"Reverse queries selection","");
	$queries_toolbar->insert($queries_reverse,-1);
		
	$queries->pack_start($queries_toolbar,FALSE,FALSE,0);
	
	############################################################################
	# Queries Frame
	my $queries_frame = Gtk2::Frame->new();
	   # Queries Scrolled Window
	   my $queries_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$queries_sw->set_policy('automatic','automatic');

      # Create simple list
		$queries_list = Gtk2::SimpleList->new (
			"" => 'bool',
			"Queries" => 'text',
		);
		
		# Enable searching
		$queries_list->set_search_column(1);
		
		# Enable sorting
		my $queries_column = $queries_list->get_column (1);
		$queries_column->set_sort_column_id(1);
		
		# Connect signal to checkbox
		my $queries_cell = ($queries_list->get_column (0)->get_cell_renderers)[0];
		$queries_cell->signal_connect (toggled => sub {
		   my ($cell, $text_path) = @_;
		   my $active = ($queries_cell->get_active ? 0 : 1);
		   my $name = @{$queries_list->{data}}[$text_path]->[1];
		   $self->display_results();
		});	
		
		# Connect signal to selection
		$queries_list->get_selection->signal_connect (changed => sub {
		   my ($selection) = @_;
		   my ($model,$iter) = $selection->get_selected;
		   if($iter) { 
		      my $name = $model->get($iter, 1);
		   }
		});
		
		$queries_sw->add($queries_list);
		$queries_frame->add($queries_sw);
		
	   $queries->pack_start($queries_frame,TRUE,TRUE,0);
		
	$results_selection->pack_start($queries,TRUE,TRUE,0);
	
	
	############################################################################
	# Searchengines
	my $searchengines = Gtk2::VBox->new(FALSE,0);
	
	############################################################################	
	# Searchengines Toolbar
	my $searchengines_toolbar = Gtk2::Toolbar->new();
	$searchengines_toolbar->set_icon_size('menu');
	$searchengines_toolbar->set_style('icons');
	$searchengines_toolbar->set_tooltips(TRUE);
	
	############################################################################
	# Reverse searchengines list
	my $searchengines_reverse = Gtk2::ToolButton->new_from_stock('gtk-justify-fill');
	$searchengines_reverse->signal_connect('clicked' => sub {		
      $self->inverse('SEARCHENGINES');
	});
	$searchengines_reverse->set_tooltip($tooltips,"Reverse searchengines selection","");
	$searchengines_toolbar->insert($searchengines_reverse,-1);
		
	$searchengines->pack_start($searchengines_toolbar,FALSE,FALSE,0);
	
	############################################################################
	# Searchengines Frame
	my $searchengines_frame = Gtk2::Frame->new();	
	   $searchengines_frame->set_size_request('170',);
	   
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
		
		# Connect signal to checkbox
		my $searchengines_cell = ($searchengines_list->get_column (0)->get_cell_renderers)[0];
		$searchengines_cell->signal_connect (toggled => sub {
		my ($cell, $text_path) = @_;
		my $active = ($searchengines_cell->get_active ? 0 : 1);
	   	my $name = @{$searchengines_list->{data}}[$text_path]->[1];
		   $self->display_results;
		});	
		$searchengines_sw->add($searchengines_list);
		$searchengines_frame->add($searchengines_sw);
		
		$searchengines->pack_start($searchengines_frame,TRUE,TRUE,0);
		
	$results_selection->pack_start($searchengines,FALSE,TRUE,0);

   $results->pack1($results_selection,TRUE,FALSE);
   
	############################################################################
	# Results Display   
   my $results_display = Gtk2::HBox->new(FALSE,0);   
   
	############################################################################
   # Mined Results   
   my $mined_list;
   my $mined = Gtk2::VBox->new(FALSE,0);
   
	############################################################################
	# Mined Toolbar
   my $mined_toolbar = Gtk2::Toolbar->new();
	$mined_toolbar->set_icon_size('menu');
	$mined_toolbar->set_style('icons');
	$mined_toolbar->set_tooltips(TRUE);

	#########################################################################
	# Recycle Target
	my $mined_recycle = Gtk2::ToolButton->new_from_stock('gtk-refresh');
	$mined_recycle->signal_connect('clicked' => sub {
      $self->recycle_mined;    
	});
	$mined_recycle->set_tooltip($tooltips,"Recycle mined results","");
	$mined_toolbar->insert($mined_recycle,-1);
	

	############################################################################		
	# Reverse Mined List
	my $mined_reverse = Gtk2::ToolButton->new_from_stock('gtk-justify-fill');
   $mined_reverse->signal_connect('clicked' => sub {
      $self->inverse('MINED');
	});
	$mined_reverse->set_tooltip($tooltips,"Reverse mined list selection","");
	$mined_toolbar->insert($mined_reverse,-1);
		
	$mined->pack_start($mined_toolbar,FALSE,FALSE,0);


	############################################################################
	# Mined Frame   
   my $mined_frame = Gtk2::Frame->new();
      $mined_frame->set_size_request('170',);
      
      # Mined Results Scrolled Window
      my $mined_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$mined_sw->set_policy('automatic','automatic');

      # Create simple list
		$mined_list = Gtk2::SimpleList->new (
			"" => 'bool',
			"Mined" => 'text',
		);
		
		# Enable searching
		$mined_list->set_search_column(1);
		
		# Enable sorting
		my $mined_column = $mined_list->get_column (1);
		$mined_column->set_sort_column_id(1);
		
		# Connect signal to checkbox
		my $mined_cell = ($mined_list->get_column (0)->get_cell_renderers)[0];
		$mined_cell->signal_connect (toggled => sub {
   		my ($cell, $text_path) = @_;
	   	my $active = ($mined_cell->get_active ? 0 : 1);
	   	my $name = @{$mined_list->{data}}[$text_path]->[1];
	  	});
		
		# Connect signal to double-click
		$mined_list->signal_connect (row_activated => sub {
          my ($sl, $path, $column) = @_;
	       my $row_ref = $sl->get_row_data_from_path ($path);
	       $self->show_page(@$row_ref[1]);
      });
		
		$mined_sw->add($mined_list);
		$mined_frame->add($mined_sw);
	$mined->pack_start($mined_frame,TRUE,TRUE,0);
		
	$results_display->pack_start($mined,FALSE,TRUE,0);
 
	############################################################################
   # Results
   my $results_sites = Gtk2::VBox->new(FALSE,0);
   my $results_list;
   
	############################################################################
	# Results Toolbar
   my $results_toolbar = Gtk2::Toolbar->new();
	$results_toolbar->set_icon_size('menu');
	$results_toolbar->set_style('icons');
	$results_toolbar->set_tooltips(TRUE);
	
	$results_toolbar->insert(Gtk2::SeparatorToolItem->new,-1);
	$results_sites->pack_start($results_toolbar,FALSE,FALSE,0);
  
	############################################################################
	# Results Frame
   my $results_frame = Gtk2::Frame->new();
   
      # Results Scrolled Window
      my $results_sw = Gtk2::ScrolledWindow->new(undef,undef);
		$results_sw->set_policy('automatic','automatic');

      # Create simple list
		$results_list = Gtk2::SimpleList->new (
			"Results" => 'text',
		);
		
		# Enable searching
		$results_list->set_search_column(0);
		
		# Enable sorting
		my $results_column = $results_list->get_column (0);
		$results_column->set_sort_column_id(0);
		
		# Connect signal to double-click
		$results_list->signal_connect (row_activated => sub {
          my ($sl, $path, $column) = @_;
	       my $row_ref = $sl->get_row_data_from_path ($path);
	       $self->show_page(@$row_ref[0]);
      });
      		
		$results_sw->add($results_list);
		$results_frame->add($results_sw);
   $results_sites->pack_start($results_frame,TRUE,TRUE,0);
		
	$results_display->pack_start($results_sites,TRUE,TRUE,0);
	
	############################################################################
	# Results Statistics
   my $statistics_frame = Gtk2::Frame->new();
      $statistics_frame->set_size_request('170',);
   my $statistics_vbox = Gtk2::VBox->new(FALSE,0);
   
   my $statistics_label = Gtk2::Label->new;
		$statistics_label->set_markup("<span><big><b>Statistics\n</b></big></span>");
		$statistics_vbox->pack_start($statistics_label,FALSE,FALSE,0);
		
	my $statistics = Gtk2::Table->new(3,2,FALSE);   
   
   # Statistics Hits
	my $hits_label = Gtk2::Label->new("Hits: ");
	$hits_label->set_alignment(1,.5);
	$statistics->attach_defaults($hits_label,0,1,0,1);
	my $hits_count = Gtk2::Label->new(0);
	$hits_count->set_alignment(0,.5);
	$statistics->attach_defaults($hits_count,1,2,0,1);

	# Statistics Mined
	my $mined_label = Gtk2::Label->new("Mined: ");
	$mined_label->set_alignment(1,.5);
	$statistics->attach_defaults($mined_label,0,1,1,2);
	my $mined_count = Gtk2::Label->new(0);
	$mined_count->set_alignment(0,.5);
	$statistics->attach_defaults($mined_count,1,2,1,2);

	# Statistics Results
	my $results_label = Gtk2::Label->new("Results: ");
	$results_label->set_alignment(1,.5);
	$statistics->attach_defaults($results_label,0,1,2,3);
	my $results_count = Gtk2::Label->new(0);
	$results_count->set_alignment(0,.5);
	$statistics->attach_defaults($results_count,1,2,2,3);
	
	$statistics_vbox->pack_start($statistics,FALSE,FALSE,0);
   
   $statistics_frame->add($statistics_vbox);   
   $results_display->pack_start($statistics_frame,FALSE,FALSE,0);
 
   $results->pack2($results_display,TRUE,FALSE);
   
   $self->pack_start($results,TRUE,TRUE,0);
   
	############################################################################
	# Initialize common variables
   $self->{TARGETS} = $targets_list;
   $self->{QUERIES} = $queries_list;
   $self->{SEARCHENGINES} = $searchengines_list;
   
   $self->{MINED} = $mined_list;
   $self->{RESULTS} = $results_list;
   
   $self->{HITS_COUNT} = $hits_count;
   $self->{RESULTS_COUNT} = $results_count;
   $self->{MINED_COUNT} = $mined_count;
   
   $self->{DATABASE} = $database;
   $self->{PREPARATION} = $preparation;
	
	############################################################################
	# Check for new results in the queue
	Glib::Timeout->add (200, sub {
       		my ($time, $query) = Worker->done_job;
       		if($time && $query->totalhits) { 
       		   my $target = $query->target;
       		   my $query_name = $query->name;
       		   my $searchengine = $query->searchengine;
       		   my $totalhits = $query->totalhits;
       		   my $mined = $query->mined;
       		   my $results = $query->results;
       		   
       		   # save mined results
       		   my $use_mined = $database->preferences_mined;
       		   if($use_mined == 1) {
       		      foreach (@$mined) {
       		         $preparation->add_target($_);       		      
       		      }
       		   }      		   
       		             		   
       		   $self->add_target("$target");
       		   $self->add_query("$query_name");
       		   $self->add_searchengine("$searchengine");
       		   
       		   $database->result($target,$query_name,$searchengine,$totalhits,$mined,$results);
       		
       		};
        		1;
   });
   
	bless $self, $class;
	return $self;
}

###############################################################################
# Function   : new_results - clears out all results from the screen and db
# Parameters : none
# Returns    : none
sub new_results {
   my $self = shift;   

   my $database = $self->{DATABASE};

   my $targets_list = $self->{TARGETS};
   my $queries_list = $self->{QUERIES};
   my $searchengines_list = $self->{SEARCHENGINES};
   
   my $mined_list = $self->{MINED};
   my $results_list = $self->{RESULTS};

	$database->results_purge;
		
	@{$targets_list->{data}} = ();
		
	@{$queries_list->{data}} = ();
		
	@{$searchengines_list->{data}} = ();
		
	@{$mined_list->{data}} = ();
		
	@{$results_list->{data}} = ();
	
}

sub inverse {
   my ($self,$type) = @_;
   my $list = $self->{$type};
   my $database = $self->{DATABASE};
   
	foreach (@{$list->{data}}) {
		$_->[0] = !$_->[0];
	}
	unless($type eq 'MINED') { $self->display_results }
}

sub selectall {
   my ($self,$type) = @_;
   my $list = $self->{$type};
   my $database = $self->{DATABASE};
   
	foreach (@{$list->{data}}) {
		$_->[0] = 1;
	}
	unless($type eq 'MINED') { $self->display_results }
}

sub deselectall {
   my ($self,$type) = @_;
   my $list = $self->{$type};
   my $database = $self->{DATABASE};
   
	foreach (@{$list->{data}}) {
		$_->[0] = 0;
	}
	unless($type eq 'MINED') { $self->display_results }
}

###############################################################################
# Function   : add_target - adds target to the Results Targets list
# Parameters : target name
# Returns    : none
sub add_target {
   my($self, $target) = @_;
   my $targets_list = $self->{TARGETS};
   foreach (@{$targets_list->{data}}) { if(@$_[1] eq $target) { return } }
   push @{$targets_list->{data}}, [FALSE, $target];
}

###############################################################################
# Function   : remove_target - removes target from the Results Targets list
# Parameters : target name
# Returns    : none
sub remove_target {
   my $self = shift;   
   my $targets_list = $self->{TARGETS};
   my $database = $self->{DATABASE};

	my @selected = $targets_list->get_selected_indices;
	foreach my $index (@selected) {
	   $database->results_remove_target(@{$targets_list->{data}}[$index]->[1]);
		splice @{$targets_list->{data}}, $index, 1;
	}
}

###############################################################################
# Function   : add_query - adds query to the Queries list
# Parameters : query name
# Returns    : none
sub add_query {
   my($self, $query) = @_;
   my $queries_list = $self->{QUERIES};
   foreach (@{$queries_list->{data}}) { if(@$_[1] eq $query) { return } }
   push @{$queries_list->{data}}, [FALSE, $query];
}

###############################################################################
# Function   : add_searchengine - adds search engine to the Search Engine list
# Parameters : searchengine name
# Returns    : none
sub add_searchengine {
   my($self, $searchengine) = @_;
   my $searchengines_list = $self->{SEARCHENGINES};
   foreach (@{$searchengines_list->{data}}) { if(@$_[1] eq $searchengine) { return } }
   push @{$searchengines_list->{data}}, [FALSE, $searchengine];
}

###############################################################################
# Function   : add_mined - adds mined domain to the Mines list
# Parameters : mined name
# Returns    : none
sub add_mined {
   my($self, $mined) = @_;
   my $mined_list = $self->{MINED};
   push @{$mined_list->{data}}, [TRUE,$mined];
}

###############################################################################
# Function   : recycle_mined - recycles a mined result for future scans
# Parameters : none
# Returns    : none
sub recycle_mined {
   my $self = shift;   
   my $mined_list = $self->{MINED};
   my $preparation = $self->{PREPARATION};
   foreach (@{$mined_list->{data}}) { 
     if(@$_[0]) { 
       $preparation->add_target(@$_[1]);
     } 
   }  
}

###############################################################################
# Function   : add_result - adds result to the Results list
# Parameters : result site name
# Returns    : none
sub add_result {
   my($self, $result) = @_;
   my $results_list = $self->{RESULTS};
   push @{$results_list->{data}}, $result;
}

###############################################################################
# Function   : display_results - displays results in accordance to user selection
# Parameters : none
# Returns    : none
sub display_results {
   my $self = shift;
   
   ############################################################################
   # Prepare variables
   my $database = $self->{DATABASE};
      
   my $targets_list = $self->{TARGETS};
   my $queries_list = $self->{QUERIES};
   my $searchengines_list = $self->{SEARCHENGINES};   
   
   my $results_list = $self->{RESULTS};
   my $mined_list = $self->{MINED};
   
   my $hits_count = $self->{HITS_COUNT};
   my $results_count = $self->{RESULTS_COUNT};
   my $mined_count = $self->{MINED_COUNT};
   
   my ($hits_counter, $results_counter, $mined_counter) = (0,0,0);
      
   ############################################################################
   # Clear results and mined list before filling
	@{$results_list->{data}} = ();
	
	@{$mined_list->{data}} = ();
	
	############################################################################
	# Display results
	my (%mined_hash,%results_hash);
	
   foreach my $target (@{$targets_list->{data}}) {
      if($$target[0] && $database->get_result($$target[1])) {
         foreach my $query (@{$queries_list->{data}}) { 
            if($$query[0] && $database->get_result($$target[1], $$query[1])) {
               foreach my $searchengine (@{$searchengines_list->{data}}) { 
                  if($$searchengine[0] && $database->get_result($$target[1], $$query[1], $$searchengine[1])) {
                     my $query_result = $database->get_result($$target[1], $$query[1], $$searchengine[1]);
                     my $totalhits = $$query_result{TOTALHITS};
                     my $mined = $$query_result{MINED};
                     my $results = $$query_result{RESULTS};
                     
                     if($totalhits) { $hits_counter += $totalhits }
                     foreach (@$mined) {
                        $mined_hash{$_} = undef;
                     }
                     foreach (@$results) {
                        $results_hash{$_} = undef;
                     }
                  }
               }
            }
         }
      } 
   }
   
   foreach (keys %mined_hash)   { 
      $self->add_mined($_);  
      $mined_counter++;   
   }
   foreach (keys %results_hash) { 
      $self->add_result($_); 
      $results_counter++;
   }
   
   $hits_count->set_text($hits_counter);
   $results_count->set_text($results_counter);
   $mined_count->set_text($mined_counter);
   
}
###############################################################################
# Function   : save_results - saves results to a specified file
# Parameters : none
# Returns    : none
sub save_results {
   my $self = shift;
   my $database = $self->{DATABASE};
   
   ############################################################################
   # First get file name and file type to save the report
   my $file_chooser = Gtk2::FileChooserDialog->new (
                        'Save', undef, 'save',
                        'gtk-cancel' => 'cancel',
                        'gtk-ok' => 'ok'
   );

   # suggest default save file
   my $type = "html";
   my $timestamp = time;
   $file_chooser->set_current_name("seat-report-$timestamp.$type");
   
   # save type selector
   my $hbox = Gtk2::HBox->new(FALSE,0);
   
   my $label = Gtk2::Label->new("Select Type:     ");
   $hbox->pack_start($label,FALSE,FALSE,0);
   
   my $cb = Gtk2::ComboBox->new_text;
   $cb->append_text("html");
   $cb->append_text("mined.html");
   $cb->append_text("results.html");
   $cb->append_text("txt");
   $cb->append_text("mined.txt");   
   $cb->append_text("results.txt");
   
   $cb->signal_connect('changed' => sub {
      $type = $cb->get_active_text;
      $file_chooser->set_current_name("seat-report-$timestamp.$type");
   });
   $cb->set_active(0);
   
   $hbox->pack_start($cb,TRUE,TRUE,0);
   $hbox->show_all;
   
   $file_chooser->set_extra_widget($hbox);
   
   my $filename;
   if('ok' eq $file_chooser->run) {
      $filename = $file_chooser->get_filename;
   }   
   $file_chooser->destroy;
   
   if($cb->get_active_text eq "html") { ReportGen->html($filename,$database); }
   if($cb->get_active_text eq "mined.html") { ReportGen->html_mined($filename,$database); }
   if($cb->get_active_text eq "results.html") { ReportGen->html_results($filename,$database); }
   if($cb->get_active_text eq "txt") { ReportGen->txt($filename,$database); }
   if($cb->get_active_text eq "mined.txt") { ReportGen->txt_mined($filename,$database); }
   if($cb->get_active_text eq "results.txt") { ReportGen->txt_results($filename,$database); }
   
}

###############################################################################
# Function   : show_page - display available resources for the selection
# Parameters : result name
# Returns    : none
sub show_page {
   my ($parent,$page) = @_;   
	$parent = $parent->get_parent->get_parent->get_parent;
	
   my $dialog = Gtk2::Dialog->new("SEAT: Display Page",$parent,'destroy-with-parent',
											 'gtk-open'   => 'accept',
											 'gtk-cancel' => 'cancel');
	my $page_label = Gtk2::Label->new;
	$page_label->set_markup("<span><b>The following resources are available for:</b></span>");
	$page_label->set_alignment(0,1);
	$dialog->vbox->add($page_label);
	
	my $page_entry = Gtk2::Entry->new;
	$page_entry->set_text($page);
	$page_entry->set_size_request(200,);
	$dialog->vbox->add($page_entry);
	
	# Resources Selection
	my $resources_frame = Gtk2::Frame->new();
	   $resources_frame->set_size_request(200,200);
	# Resources Scrolled Window
	my $resources_sw = Gtk2::ScrolledWindow->new(undef,undef);
	   $resources_sw->set_policy('automatic','automatic');

   # Create simple list
	my $resources_list = Gtk2::SimpleList->new (
		"" => 'bool',
		"Resources" => 'text',
	);
				
	# Enable searching
	$resources_list->set_search_column(1);
		
  	# Enable sorting
	my $resources_column = $resources_list->get_column (1);
	$resources_column->set_sort_column_id(1);
		
	# Connect signal to checkbox	
	my $resources_cell = ($resources_list->get_column (0)->get_cell_renderers)[0];
	   $resources_cell->signal_connect (toggled => sub {
	   my ($cell, $text_path) = @_;
	   my $active = ($resources_cell->get_active ? 0 : 1);
	   my $name = @{$resources_list->{data}}[$text_path]->[1];
	});	
		
	# Connect signal to selection
	$resources_list->get_selection->signal_connect (changed => sub {
	   my ($selection) = @_;
	   my ($model,$iter) = $selection->get_selected;
	   if($iter) { 
	      my $name = $model->get($iter, 1);
	   }
	});
	
	# Add default resources
	push @{$resources_list->{data}}, [FALSE, "Direct Request"];
	push @{$resources_list->{data}}, [TRUE, "Netcraft.com"];
	push @{$resources_list->{data}}, [TRUE, "Archive.org"];
	push @{$resources_list->{data}}, [TRUE, "Google Cache"];
		
	$resources_sw->add($resources_list);
	$resources_frame->add($resources_sw);
		
	$dialog->vbox->add($resources_frame);
	
	# Warning message
	my $warning_label = Gtk2::Label->new;
	$warning_label->set_markup("<span foreground='red'><b>Warning!</b>\nSome resources can potentially reveal your source IP address</span>");
	$warning_label->set_alignment(0,1);
	$dialog->vbox->add($warning_label);
	
	$dialog->show_all;
	
	# Display resources
	$dialog->signal_connect(response => sub {
		if($_[1] =~ m/accept/){
		   my @parameters;
		   my $page = $page_entry->get_text;
		   foreach (@{$resources_list->{data}}) { 
		      if(@$_[0]) {
   		      if(@$_[1] eq "Direct Request") { push @parameters, $page; }
	   	      if(@$_[1] eq "Netcraft.com") { push @parameters, "http://toolbar.netcraft.com/site_report?url=$page"; }
	   	      if(@$_[1] eq "Archive.org") { push @parameters, "http://web.archive.org/web/*/$page"; }
	   	      if(@$_[1] eq "Google Cache") { push @parameters, "http://72.14.253.104/search?q=cache:$page"; }
	   	      if(@$_[1] eq "Google Translate") { push @parameters, "http://www.google.com/translate?u=$page&langpair=en%7C"; }
	         }	   
		   }
 	      if(@parameters) { system("firefox @parameters"); }
		}
		else {
			$dialog->destroy;
		}
	});
}

1;
