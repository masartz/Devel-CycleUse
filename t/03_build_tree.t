use strict;
use warnings;

use Test::More;
use Test::MockModule;

use Devel::CycleUse;

subtest 'normal' => sub {
    my $instance = Devel::CycleUse->new(dir => "hoge");
    $instance->use_module_tree;
};

done_testing;
