package Devel::CycleUse;
use 5.008005;
use strict;
use warnings;
our $VERSION = "0.01";

use File::Find;
use File::Slurp qw(read_file);

sub find_file {
    my ($path) = @_;

    my @target_files;
    my $callback = sub {
        my $file = $File::Find::name;
        return unless $file =~ m/\.pm$/;
        push @target_files, $file;
    };

    find($callback, $path);

    return \@target_files;
}

sub extract_using_modules {
    my (@content) = @_;

    my $package;
    my @using_modules;
    for (@content) {
        if ($_ =~ /^package\s+([A-Za-z0-9:]+);/) {
            $package = $1;
            push @using_modules, $package, [];
            next;
        }

        if ($package && $_ =~ /^use\s([A-Za-z0-9:._]+)/) {
            my $use_module = $1;

            if ($use_module =~ /strict|warnings|utf8|[0-9.]+|vars|base|parent|constant/) {
                next;
            }
            if ($use_module =~ /::$/) {
                next;
            }
            my $flag;
            for (@{$using_modules[-1]}) {
                $flag = 1 if ($_ eq $use_module);
            }
            next if $flag;
            push @{$using_modules[-1]}, $use_module;
        }
    }

    return @using_modules;
}

sub build_tree {
    my ($target_files) = @_;
    my %use_tree;

    for my $file (@$target_files) {
        my @content = read_file($file, chomp => 1);
        my @using_modules = extract_using_modules(@content);
        while (@using_modules) {
            my $package = shift @using_modules;
            my $modules = shift @using_modules;
            $use_tree{$package} = $modules;
        }
    }

    return \%use_tree;
}

sub detect_cycle_use {
    my ($tree) = @_;
    my @result;

    my $cycle_use = sub {
        my ($target_node) = @_;
        my %mark;

        my $visit_node;$visit_node = sub {
            my ($node, $route) = @_;
            for (@$route) {
                if ($_ eq $node) {
                    push @result, [@$route, $_];
                    last;
                }
            }

            unless (exists $mark{$node}) {
                $mark{$node} = 1;
                for my $to_node (@{$tree->{$node}}) {
                    $visit_node->($to_node, [@$route, $node]);
                }
            }
        };

        $visit_node->($target_node, []);
    };

    for my $target_node (keys %$tree) {
        $cycle_use->($target_node);
    }

    return \@result;
}

sub find_cycle {
    my ($lists) = @_;

    my %deflate;
    for my $list (@$lists) {
        my @small_cycle;
        for (reverse @$list) {
            for my $small (@small_cycle) {
                if ($small eq $_) {
                    push @small_cycle, $_;
                    goto FIND_CYCLE_END;
                }
            }
            push @small_cycle, $_;
        }

        FIND_CYCLE_END:
        my $key = join "", @small_cycle;
        unless (exists $deflate{$key}) {
            $deflate{$key} = \@small_cycle;
        }
    }

    for my $cycle (values %deflate) {
        if (@$cycle == 2) {
            if ($cycle->[0] eq $cycle->[1]) {
                next;
            }
        }
        print join(" -> ", reverse(@$cycle))."\n";
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Devel::CycleUse - It's new $module

=head1 SYNOPSIS

    use Devel::CycleUse;

=head1 DESCRIPTION

Devel::CycleUse is ...

=head1 LICENSE

Copyright (C) Fumihiro Itoh.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Fumihiro Itoh E<lt>fmhrit@gmail.comE<gt>

=cut

