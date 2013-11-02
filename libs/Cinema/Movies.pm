package Homyaki::Cinema::Movies;

use DateTime;

use strict;
use base 'Homyaki::Cinema::DB';

__PACKAGE__->table('movies');
__PACKAGE__->columns(Primary   => qw/id/);
__PACKAGE__->columns(Essential => qw/torrent_path name rating deleted/);


1;
