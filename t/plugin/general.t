#!/usr/bin/perl
# $Id: general.t,v 1.1 2003/03/12 20:42:39 cwest Exp $
use strict;
$^W = 1;

use Test::More qw[no_plan];
use lib qw[lib ../lib];

BEGIN {
	use_ok 'POEST::Server';
}

