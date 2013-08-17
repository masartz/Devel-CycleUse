package Devel::CycleUse;
use 5.008005;
use strict;
use warnings;
our $VERSION = "0.01";

use File::Find;
use File::Slurp qw(read_file);
use Carp qw(croak);

sub new {
    my ($class, %args) = @_;

    croak "dir is required" unless $args{dir};

    return bless {
        dir => $args{dir}
    }, $class;
}

sub target_files {
    my ($self) = @_;
    return $self->{target_files} if $self->{target_files};

    my @target_files;
    my $callback = sub {
        my $file = $File::Find::name;
        return unless $file =~ m/\.pm$/;
        push @target_files, $file;
    };

    find($callback, $self->{dir});

    $self->{target_files} = \@target_files;
    return $self->{target_files};
}

sub __extract_using_modules {
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

sub use_module_tree {
    my ($self) = @_;
    return $self->{use_module_tree} if $self->{use_module_tree};
    my %use_tree;

    for my $file (@{$self->target_files}) {
        my @content = read_file($file, chomp => 1);
        my @using_modules = __extract_using_modules(@content);
        while (@using_modules) {
            my $package = shift @using_modules;
            my $modules = shift @using_modules;
            $use_tree{$package} = $modules;
        }
    }

    $self->{use_module_tree} = \%use_tree;
    return $self->{use_module_tree};
}

sub cycle_use_list {
    my ($self) = @_;
    return $self->{cycle_use_list} if $self->{cycle_use_list};
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
                for my $to_node (@{$self->use_module_tree->{$node}}) {
                    $visit_node->($to_node, [@$route, $node]);
                }
            }
        };

        $visit_node->($target_node, []);
    };

    for my $target_node (keys %{$self->use_module_tree}) {
        $cycle_use->($target_node);
    }

    $self->{cycle_use_list} = \@result;
    return $self->{cycle_use_list};
}

sub find_small_cycle {
    my ($self) = @_;
    return $self->{result} if $self->{result};

    my %deflate;
    for my $list (@{$self->cycle_use_list}) {
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

    my @lists;
    for my $cycle (values %deflate) {
        if (@$cycle == 2) {
            if ($cycle->[0] eq $cycle->[1]) {
                next;
            }
        }
        push @lists, $cycle;
    }

    my %uniq_map = map {__make_array_key($_) => $_} reverse @lists;
    @lists = values %uniq_map;

    $self->{result} = \@lists;
    return $self->{result};
}

sub print {
    my ($self) = @_;

    for (@{$self->find_small_cycle}) {
        print join(" -> ", @$_)."\n";
    }
}

sub __make_array_key {
    my ($list) = @_;

    my %list_map = map {$_ => 1} @$list;
    return join("", sort keys %list_map)
}

1;
__END__

=encoding utf-8

=head1 NAME

Devel::CycleUse -

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

