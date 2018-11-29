###############################################################################
# Package    : Worker
# Description: Used to control and spawn threads
package Worker;

use strict;
use warnings;

use threads;
use threads::shared;
use Thread::Queue::Any;

use Glib qw(TRUE FALSE);

use base 'Gtk2::HBox';

our $_nworkers : shared = 0;  # number of active workers/threads
my $_jobs;                    # queue of jobs waiting to be processed
my $_jobs_done;               # queue of completed jobs waiting to be analyzed

our $_status : shared = 2;    # default execution status

BEGIN
{
	$_jobs = Thread::Queue::Any->new;
	$_jobs_done = Thread::Queue::Any->new;
}

###############################################################################
# Function   : do_job - enqueues a job object into the Jobs Queue 
# Parameters : job id, job object
# Returns    : none
sub do_job {
	my ($class, $num, $query_obj) = @_;
	$_jobs->enqueue ($num, $query_obj);
}

###############################################################################
# Function   : done_job - enqueues a done job object into the Jobs Done Queue 
#              and dequeues a done job object for analysis
# Parameters : job id, job object
# Returns    : job id, job object
sub done_job {
   my ($class,$job,$query_obj) = @_;
   if($query_obj) { $_jobs_done->enqueue($job,$query_obj); }
   else { return $_jobs_done->dequeue_nb; }

}

###############################################################################
# Function   : status - 2 - lets Workers know that processing should stop and
#                           they should clean up the Jobs Queue instead
#                       1 - lets Workers know to pause their execution
#                       0 - lets Workers process job objects in the queue
# Parameters : int
# Returns    : none
sub status {
   shift; #class
   if (@_) { $_status = shift }
   return $_status;
}

###############################################################################
# Function   : jobs_pending - counts the number of jobs pending in Jobs Queue 
# Parameters : none
# Returns    : int
sub jobs_pending {
   shift; #class
	return $_jobs->pending;
}

###############################################################################
# Function   : new - Instantiates new Workers and starts threads
# Parameters : worklog
# Returns    : Worker
sub new {
	my ($class, $worklog, $database) = @_;  

	my $self = Gtk2::HBox->new (FALSE, 1);

	# rebless to a worker
	bless $self, $class;

	# gui section	
	my $progress = Gtk2::ProgressBar->new;
	$progress->set_orientation('bottom-to-top');
	$progress->set_size_request('50',);
	$self->pack_start ($progress, TRUE, TRUE, 1);

	$self->{PROGRESS} = $progress;
	$self->{WORKLOG} = $worklog;
	$self->{DATABASE} = $database;
	
	# thread section
	$self->{child} = threads->new (\&_worker_thread, $self);

	return $self;
}

###############################################################################
# Function   : set_worker_label - dynamically sets progress bar label, used to
#                                 display percentage and status changes
# Parameters : name
# Returns    : none
sub set_worker_label {
	my $self = shift;
	my $name = shift;

	$self->{PROGRESS}->set_text ($name);
}

###############################################################################
# Function   : _worker_thread - the thread itself which takes the next job in
#                               the Jobs Queue and processes it. If status was
#                               changed, it simply pops it from the queue thus
#                               clearing it. Sleep time and Threads number are
#                               checked every time for more dynamic control.
# Parameters : none
# Returns    : none
sub _worker_thread {
	my $self = shift;

	my $progress = $self->{PROGRESS};
	my $worklog = $self->{WORKLOG};
	my $database = $self->{DATABASE};

	my ($job, $query_obj);
		
	while (($job, $query_obj) = $_jobs->dequeue) {
	   $_nworkers++;
		
		# if status was not changed go ahead with the job
		# otherwise just take out the job and sleep a bit
		# NOTE: we need to sleep in order to keep gui active
		unless($_status == 2) {  
	   	$query_obj->process($worklog,$progress,$database);
      	sleep $database->preferences_sleep;	      	   
	   }
	   
	   $_nworkers--;
	   
	   # loop until less workers are active
	   while($_status == 1 || $_nworkers > $database->preferences_threads) {
	      sleep 1;
	   }
	}	
}

1;
