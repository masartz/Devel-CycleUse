use strict;
use warnings;

use Devel::CycleUse;
use Data::Dumper;

Devel::CycleUse->new(dir => $ARGV[0])->print;
