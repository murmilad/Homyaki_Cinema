package Homyaki::Task_Manager::Task::Build_Cinema;

use strict;

use DateTime;
use LWP::UserAgent;

use Encode; 
use Net::BitTorrent::File;

use Homyaki::Logger;

use Homyaki::Task_Manager::DB::Task;
use Homyaki::Cinema::Movies;

use Data::Dumper;

use constant TORRENTS_PATH    => '/home/alex/Share/torrents/';

sub start {
	my $class = shift;
	my %h = @_;
	
	my $params = $h{params};
	my $task   = $h{task};

	if (-d &TORRENTS_PATH) {
		if (opendir(my $dh, &TORRENTS_PATH)){
			my @torrent_files = grep { /\.torrent$/} readdir($dh);
	    	closedir $dh;
			foreach my $torrent_file (@torrent_files) {
				my @exist = Homyaki::Cinema::Movies->search(
					torrent_path => &TORRENTS_PATH . $torrent_file
				);
				if (scalar(@exist) == 0) {
					my $torrent_data = load_film_data($torrent_file);
					if ($torrent_data->{header}) {
						Homyaki::Cinema::Movies->insert({
							torrent_path => &TORRENTS_PATH . $torrent_file,
							name         => $torrent_data->{header},
							deleted      => 0,
						});
					}
				}
			}
		}
	}

	my $result = {
		result => {code  => 'ok'},
	};


	$result->{task} = {
		retry => {
			minutes => 1,
		},
	};

	return $result;
}

sub load_film_data {
	my $file_name = shift;

	my $data = {};
	my $torrent;
	eval{ $torrent = Net::BitTorrent::File->new(&TORRENTS_PATH . $file_name)};

	if ($@) {
		Homyaki::Logger::print_log("torrent data error: $@ for " . &TORRENTS_PATH . $file_name);
	}
	if ($torrent) {
		$data->{body} = $torrent;
		my $source_uri = $torrent->{data}->{comment};

		if ($source_uri){
			my $browser;

			$browser = LWP::UserAgent->new('cookie_jar' => { file => ".lwpcookies.txt", autosave => 1 });
			my $result  = {};

			my $headers = new HTTP::Headers(
				'Content_Type' => 'application/x-www-form-urlencoded',
				'Accept'       => 'multipart/form-data',
				'User-Agent'   => 'IE+/5.0'
			);

			my $response = $browser->get($source_uri, $headers);
			if ($response->is_success) {
				my $content = $response->decoded_content;
				if ($content =~ /<title>(.+)<\/title>/){
					$data->{header} = encode('UTF_8', $1);
				}
			}

		} else {
			Homyaki::Logger::print_log("Cant get torrent url for " . &TORRENTS_PATH . $file_name);
		}
	} else {
		Homyaki::Logger::print_log("Cant get torrent data for " . &TORRENTS_PATH . $file_name);
	}
	return $data;
}
1;
#Homyaki::Task_Manager::Task::Build_Cinema->start();
__END__
		use Homyaki::Task_Manager::DB::Task_Type;
		use Homyaki::Task_Manager;
		my @task_types = Homyaki::Task_Manager::DB::Task_Type->search(
			handler => 'Homyaki::Task_Manager::Task::Build_Cinema'
		);

		if (scalar(@task_types) > 0) {

			my $task = Homyaki::Task_Manager->create_task(
				task_type_id => $task_types[0]->id(),
				modal        => 1,
			);
		}
