use strict;
use warnings;
use Test::More;
use Test::Output;
use Test::MockModule;

use Devel::CycleUse::CLI;

subtest 'print' => sub{
    my $mock_cycle = Test::MockModule->new( 'Devel::CycleUse::CLI' );

    $mock_cycle->mock( '__find_small_cycle' , sub{
        [qw/aaaa bbbb cccc dddd/],
    } );


    stdout_is( 
        sub { Devel::CycleUse::CLI->print({
            dir => 'hoge' , sort => 'ASC' }
        ) },
        "total 4 module : aaaa -> bbbb -> cccc -> dddd\n",
        "test STDOUT"
    );
};

subtest '__sort_list' => sub{

    my @random_array = (
        [qw/aaa bbb ccc/],
        [qw/aaaa bbbb cccc dddd/],
        [qw/aa bb/],
    );

    subtest 'order error' => sub{
        my @no_change = Devel::CycleUse::CLI::__sort_list(
            'ASCC' , @random_array
        );
        is_deeply \@no_change , \@random_array , 'order error';
    };

    subtest 'order asc' => sub{
        my @asc = Devel::CycleUse::CLI::__sort_list(
            'ASC' , @random_array
        );
        is_deeply \@asc , [
            [qw/aa bb/],
            [qw/aaa bbb ccc/],
            [qw/aaaa bbbb cccc dddd/],
        ] , 'order asc';
    };

    subtest 'order desc' => sub{
        my @desc = Devel::CycleUse::CLI::__sort_list(
            'DESC' , @random_array
        );
        is_deeply \@desc , [
            [qw/aaaa bbbb cccc dddd/],
            [qw/aaa bbb ccc/],
            [qw/aa bb/],
        ] , 'order desc';
    };
};

done_testing;
