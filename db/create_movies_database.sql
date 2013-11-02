CREATE DATABASE cinema;
USE cinema;
CREATE TABLE `movies` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `torrent_path` char(255) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `name` char(255) NOT NULL,
  `deleted` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=76 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

