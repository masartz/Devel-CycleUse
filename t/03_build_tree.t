use strict;
use warnings;

use Test::More;
use Test::MockModule;

use Devel::CycleUse;

subtest 'normal' => sub {
    my $instance = Devel::CycleUse->new(dir => "hoge");
    $instance->build_tree;
};

done_testing;
