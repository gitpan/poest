#!/usr/bin/perl
# $Id: Build.PL,v 1.2 2003/03/22 17:06:16 cwest Exp $
use strict;
$^W = 1;
use Module::Build;

Module::Build->new(
	dist_name         => 'poest',
	dist_version_from => 'bin/poest',
	dist_version      => do { # for pre releases only
		my @l  = localtime;
		$l[5] += 1900;
		$l[4]++;
		sprintf "0.%4d%02d%02d", @l[5,4,3];
	},
	license           => 'perl',
	requires          => {
		'perl'                         => '5.5.3',
		'POE'                          => '0.25',
		'POE::Component::Server::SMTP' => 0,
		'POE::Session::MultiDispatch'  => 0,
	},
	recommends        => {
		'Config::General'              => 0,
	},
	build_requires    => {
		'Test::More'                   => 0,
	},
	scripts                            => [ qw[
		bin/poest
	] ],
	sign              => 1,
)->create_build_script;
