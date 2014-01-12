package Homyaki::Interface::Cinema::Main;

use strict;

use Data::Dumper;

use Homyaki::Tag;
use Homyaki::HTML;
use Homyaki::HTML::Constants;
use Homyaki::Cinema::Movies;

use Homyaki::Logger;

use Homyaki::Interface;
use base 'Homyaki::Interface::Interface_Helper';

use constant PARAMS_MAP  => {
};


sub get_form {
	my $self = shift;
	my %h = @_;

	my $params   = $h{params};
	my $errors   = $h{errors};
	my $user     = $h{user};

	my $body_tag = $h{body_tag};

	my $form = $body_tag;

	Homyaki::HTML->add_login_link(
		user      => $user,
		body      => $form,
		interface => 'main',
		auth      => 'auth',
		params    => $params,
	);

	my $permissions = $user->{permissions};

	foreach my $movie (sort {$b->{rating} <=> $a->{rating}} sort {$b->{id} <=> $a->{id}}  @{$params->{movies}}){
		my $form_param = $form->add_form_element(
			name   => 'mark',
			type   => &INPUT_TYPE_LABEL,
			value  => '>',
		);
		if (ref($permissions) eq 'ARRAY' && grep {$_ eq 'writer'} @{$permissions}){
			$form_param = $form_param->add_form_element(
				name   => "name_$movie->{id}",
				type   => &INPUT_TYPE_TEXT,
				value  => $movie->{name},
				location => &LOCATION_RIGHT,
				&PARAM_SIZE => "100",
			);
			$form_param = $form_param->add_form_element(
				name     => "rating_$movie->{id}",
				type     => &INPUT_TYPE_NUMBER,
				value    => $movie->{rating},
				location => &LOCATION_RIGHT,
				&PARAM_SIZE => "2",
			);
			$form_param = $form_param->add_form_element(
				name     => "delete_$movie->{id}",
				type     => &INPUT_TYPE_CHECK,
				location => &LOCATION_RIGHT,
			);
		} else {
			$form_param = $form_param->add_form_element(
				name   => 'cinema_name',
				type   => &INPUT_TYPE_LABEL,
				value  => $movie->{name},
				location => &LOCATION_RIGHT,
			);
			$form_param = $form_param->add_form_element(
				name     => 'cinema_rating',
				type     => &INPUT_TYPE_LABEL,
				value    => $movie->{rating},
				location => &LOCATION_RIGHT,
			);
			$form->add_form_element(
				name   => 'cinema_line',
				type   => &INPUT_TYPE_LABEL,
				value  => '&nbsp;',
			)
		}
		
	}

	if (ref($permissions) eq 'ARRAY' && grep {$_ eq 'writer'} @{$permissions}){
		$form->add_submit_button(
			header   => 'Change',
		);
	}

	return {
		root => $body_tag->{root},
		body => $body_tag,
	};
}

sub get_params {
	my $self = shift;
	my %h = @_;

	my $params      = $h{params};
	my $user        = $h{user};
	my $permissions = $user->{permissions};
	
	my $result = $params;

	my @movies = Homyaki::Cinema::Movies->search(
		deleted => 0
	);

	$params->{movies} = \@movies;

	return $result;
}

sub set_params {
	my $self = shift;
	my %h = @_;

	my $params      = $h{params};
	my $user        = $h{user};
	my $permissions = $user->{permissions};
	
	my $result = $params;

	my @movies = Homyaki::Cinema::Movies->search(
		deleted => 0
	);

	foreach my $movie (@movies) {
		if ($params->{"delete_$movie->{id}"}) {
			$movie->deleted(1);
			$movie->update();
		}
		if ($params->{"name_$movie->{id}"} ne $movie->{name}) {
			$movie->name($params->{"name_$movie->{id}"});
			$movie->update();
		}
		if ($params->{"rating_$movie->{id}"} != $movie->{rating}) {
			$movie->rating($params->{"rating_$movie->{id}"});
			$movie->update();
		}
	}

	return {};
}


1;
