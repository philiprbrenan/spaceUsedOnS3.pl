#!/usr/bin/perl
#-------------------------------------------------------------------------------
# Sum up the space you are, or I am, using on Amazon AWS S3
# Philip R Brenan at gmail dot com, Appa Apps Ltd, 2017
#-------------------------------------------------------------------------------

=pod

 Parameters:   Description:
 --buckets     Optional regular expression to choose the buckets to be summed
 --profile     Optional aws cli --profile keyword to choose the account to sum

 Examples:

 perl spaceUsedOnS3.pl
 perl spaceUsedOnS3.pl --profile abc --buckets "\Ap"

 Notes:

 You will need IAM permissions for the credentials identified by the --profile
 keyword to list buckets and objects associated with the credentials.

 The buckets selection regular expression is applied in a case insensitive
 manner.

=cut

require v5.16;
use warnings FATAL => qw(all);
use strict;
use Data::Table::Text qw(:all);
use Getopt::Long;

my ($profile, $bucketr);
GetOptions
 ('profile=s' =>\$profile,
  'buckets=s' =>\$bucketr,
 );
my $Profile = $profile ? "--profile $profile" : '';                             # Add profile keyword

my $buckets = qx(aws s3 ls $Profile);                                           # Buckets
my @buckets = map {(split /\s+/, $_)[2]} split /\n/, $buckets;
pop @buckets for 1..2;                                                          # Remove extraneous entries

my $objectsTotal;                                                               # Totals
my $sizeTotal;
my @results;

for my $bucket(@buckets)                                                        # Each bucket
 {next if $bucketr and $bucket !~ /$bucketr/i;                                  # Choose buckets
  my $c = "aws s3 ls s3://$bucket $Profile --recursive --human-readable --summarize";
  my $r = qx($c);
  my ($objects)      = $r =~ m/Total Objects:\s+(\d+)/;
  my ($size, $scale) = $r =~ m/Total Size:\s([0-9.]+)\s+(\w+)/;

  $size *= (1024**1) if $scale =~ m/KiB/;
  $size *= (1024**2) if $scale =~ m/MiB/;
  $size *= (1024**3) if $scale =~ m/GiB/;
  $size *= (1024**4) if $scale =~ m/TiB/;
  $size *= (1024**5) if $scale =~ m/PiB/;
  $size  = int($size);
  push @results, [$bucket, $size, $objects];
  $objectsTotal += $objects;
  $sizeTotal    += $size;
 }

push @results, ["Total size ",   $sizeTotal],                                   # Totals
               ["Total objects", '',                 $objectsTotal],
               ["Scale",         '1501209006003000', '9006003000'];

say STDERR formatTableBasic([[qw(Bucket Size Count)], @results]);               # Results
