use strict;
use warnings;

use Devel::CycleUse;
use Data::Dumper;

my $target_files = Devel::CycleUse::find_file($ARGV[0]);
exit 1 unless $target_files;
my $tree = Devel::CycleUse::build_tree($target_files);
exit 1 unless $tree;
my $cycle_list = Devel::CycleUse::detect_cycle_use($tree);
exit 1 unless $cycle_list;
Devel::CycleUse::find_cycle($cycle_list);
