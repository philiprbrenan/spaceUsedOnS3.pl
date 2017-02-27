#!/usr/bin/perl
#-------------------------------------------------------------------------------
# Sum up the space you are, or I am, using on Amazon AWS S3
# Philip R Brenan at gmail dot com, Appa Apps Ltd, 2017
#-------------------------------------------------------------------------------

require v5.16;
use warnings FATAL => qw(all);
use strict;
use Data::Table::Text qw(:all);
use Data::Dump qw(dump);

my $buckets = qx(aws s3 ls  --recursive --human-readable --summarize);
my @buckets = map {(split /\s+/, $_)[2]} split /\n/, $buckets;
pop @buckets for 1..2;                                                          # Remove extraneous entries

my $objectsTotal;                                                               # Totals
my $sizeTotal;
my @results;

for my $bucket(@buckets)                                                        # Each bucket
 {my $c = "aws s3 ls s3://$bucket --recursive --human-readable --summarize";
# next unless $bucket =~ /phil|allan/i;
  my $r = qx($c);
  my ($objects)      = $r =~ m/Total Objects:\s+(\d+)/;
  my ($size, $scale) = $r =~ m/Total Size:\s([0-9.]+)\s+(\w+)/;
  $size *= 1e3 if $scale  =~ m/KiB/;
  $size *= 1e6 if $scale  =~ m/MiB/;
  push @results, [$bucket, $size, $objects];
  $objectsTotal += $objects;
  $sizeTotal    += $size;
 }

push @results, ["Total size ",   $sizeTotal],
               ["Total objects", '',           $objectsTotal],
               ["Scale",         '9006003000', '9006003000'];

say STDERR formatTableBasic([[qw(Bucket Size Count)], @results]);               # Results
