package Devel::CycleUse::CLI;
use 5.008005;
use strict;
use warnings;

use Devel::CycleUse;

sub print {
    my ( $class , $option ) = @_;

    my @find_small_cycle = __find_small_cycle( $option->{dir} );

    @find_small_cycle = __sort_list( $option->{sort} , @find_small_cycle );

    for my $row ( @find_small_cycle ) {
        print sprintf 'total %d module : ' , scalar @{$row} ;
        print join(' -> ', @$row)."\n";
    }
}

sub __find_small_cycle{
    my ( $dir ) = @_;

    my $cycleuse = Devel::CycleUse->new(dir => $dir);

    return @{$cycleuse->find_small_cycle};
}

sub __sort_list{
    my ( $order , @sort_array ) = @_;

    return @sort_array if $order !~ /\A(ASC|DESC)\z/;

    return $order eq 'ASC'
        ? sort { scalar @{$a} <=> scalar @{$b} } @sort_array
        : sort { scalar @{$b} <=> scalar @{$a} } @sort_array
        ;
}

1;

