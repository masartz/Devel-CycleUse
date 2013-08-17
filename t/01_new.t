use strict;
use warnings;

use Test::More;
use Test::Exception;

use Devel::CycleUse;

subtest 'new' => sub {
    subtest 'invalid params' => sub {
        dies_ok {Devel::CycleUse->new} "should be die";
    };

    subtest 'valid' => sub {
        can_ok "Devel::CycleUse", qw(new);

        ok(Devel::CycleUse->new(dir => "hoge"), "should be ok");
        isa_ok(Devel::CycleUse->new(dir => "hoge"), "Devel::CycleUse", "shoud be a Devel::CycleUse");

        my $instance = Devel::CycleUse->new(dir => "hoge");
        is $instance->{dir}, "hoge";
    };
};

done_testing;
