#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Accessors::Magic' );
}

diag( "Testing Accessors::Magic $Accessors::Magic::VERSION, Perl $], $^X" );
