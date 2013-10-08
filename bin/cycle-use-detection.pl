use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use Devel::CycleUse;

my (%opt);
GetOptions (
    'sort=s'  => \$opt{sort},
    'dir=s'   => \$opt{dir},
    "help"    => \( my $help ),
) or pod2usage(1);

$opt{sort} ||= 'ASC';
pod2usage(1) if $opt{sort} !~ /\A(ASC|DESC)\z/;
pod2usage(1) if $help;

Devel::CycleUse->new(dir => $opt{dir})->print( \%opt );

exit;

__END__

=encoding utf-8

=head1 NAME

cycle-use-detection.pl - script for finding cyclic use

=head1 SYNOPSIS

./bin/cycle-use-detection.pl [-dir DIR -sort (ASC|DESC)]

=head1 OPTIONS

=over 4

=item -dir DIR

check directory

=item -sort (ASC|DESC)

display result order by count of cyclic modules

=cut
