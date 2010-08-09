use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Accessors::Magic',
	license             => 'perl',
	dist_author         => 'Leon Timmermans <leont@cpan.org>',
	dist_version_from   => 'lib/Accessors/Magic.pm',
	build_requires => {
		'Test::More' => 0,
		'Module::Build' =>0,
	},
	add_to_cleanup      => [ 'Accessors-Magic-*' ],
	create_makefile_pl => 'traditional',
);

$builder->create_build_script();
