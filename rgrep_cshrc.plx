#!/usr/bin/perl -w
use strict;

# recursive grep cshrc files - grep the files in line like "source [filenmae]"

my $search_pattern = $ARGV[0];
my $cshrc_file = $ARGV[1];

my $indent_level;

rgrep_cshrc($search_pattern, $cshrc_file);

sub rgrep_cshrc {
    my $pattern = shift;
    my $file = shift;
    my @fields;
    my @match_lines;
    my @sourced_files;
    my $line_num;

    return unless -f $file;

    open(my $fh, "<", $file) or die "cannot open $file:$!";
    while (<$fh>) {
        chomp; $line_num++;
        next if (/\s*#/); # skip comment
        @fields = split /\s+/, $_;
        next unless (@fields);
        if ($fields[0] eq "source") {
            push @sourced_files, $fields[1];
        } else {
            if (/$pattern/) {
                push @match_lines, [$line_num, $_];
            }
        }
    }
    close($fh);

    if (@match_lines) {
        print '  'x$indent_level, "\@$file:\n";
        foreach (@match_lines) {
            print '  'x$indent_level, "Line $_->[0]: $_->[1]\n";
        }
    }

    if (@sourced_files) {
        foreach (@sourced_files) {
            print '  'x$indent_level, "source $_\n";
            $indent_level++;
            rgrep_cshrc($pattern, $_);
            $indent_level--;
        }
    }
}
   

