use 5.014002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $module = 'Module::WithCAPI';
WriteMakefile(
    NAME              => $module,
    VERSION_FROM      => 'lib/Module/WithCAPI.pm', # finds $VERSION
    PREREQ_PM         => {
#      'ExtUtils::CAPI' => '0',
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/Module/WithCAPI.pm', # retrieve abstract from module
    AUTHOR            => 'Steffen Mueller <smueller@cpan.org>',
    LIBS              => [''], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I. -I../Module-WithCAPI', # e.g., '-I. -I/usr/include/other'
);

use lib 'lib'; # TODO won't be necessary after ExtUtils::CAPI moves out of this dist
use ExtUtils::CAPI;
ExtUtils::CAPI::export_functions(
  module => $module,
  header => "module_withcapi.h",
  functions => {
    my_sum => 'int (*)(int, int)',
    my_diff => 'int (*)(int, int)',
    my_prod => 'int (*)(int, int)',
  },
);
