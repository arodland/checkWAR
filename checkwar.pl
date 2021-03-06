#! /usr/bin/perl
# Worked all redditors progress check utility by VK3DAN
# Thanks to molo1134 for borrowed code snippets.
#

use strict;
use warnings;

my $count = 0;
my $call = "";
my $band = "";
my $mode = "";
my $date = "";
my $line = "";
my $nickfile = "./nicks.csv";

print "\nUtility for checking Worked All Redditors progress from an ADIF logbook\nby VK3DAN with thanks to molo1134\n\n";

if ($#ARGV == -1)
{
    die "No adi file specified or incorrect usage\nusage: checkwar <adifile.adi>\n\n";  #show usage if called without args
}

my $adifFileName = "$ARGV[0]";

open(my $adif, $adifFileName) or die "$! -- File $ARGV[0] doesn't exist or unreadable\n\n"; #open file or show error and die
print "$adifFileName found -- ";

if (-e $nickfile ) # check for nickfile existance and if it is more than 4 weeks old prompt to download new copy
{
    if (-M "$nickfile" >= 28) 
    {
        print "Nick file may be outdated - would you like to fetch a fresh copy? (y/n)\n";
        my $freshy = <STDIN>;
        if ($freshy == "y") 
        {
            system("wget --no-verbose https://raw.githubusercontent.com/molo1134/qrmbot/master/lib/nicks.csv");
        }
    }
    print "redditor list found\n";
} else {
    print "redditor list not found: fetching\n"; # no nicks.csv file so download a copy
    system("wget --no-verbose https://raw.githubusercontent.com/molo1134/qrmbot/master/lib/nicks.csv");
}

printf("\n%-5s%-14s%-25s%-8s%-8s%-10s\n\n","#","Callsign","Reddit username","Band","Mode","Date"); 

while (my $line = <$adif>)	# process ADIF data in array
{
    if($line =~ /<CALL:\d+>([^<]*)/i)
    {  
        $call=$1;
        $call=~s/\s+$//;
    }
    if($line =~ /<MODE:\d+>([^<]*)/i)
    {
        $mode=$1;
        $mode=~s/\s+$//;
    }
    if($line =~ /<QSO_DATE:\d+:\d+>([^<]*)/i)
    {
        $date=$1;
        $date=~s/\s+$//;
    }
    if($line =~ /<QSO_DATE:\d+>([^<]*)/i)
    {
        $date=$1;
        $date=~s/\s+$//;
    }
    if($line =~ /<BAND:\d+>([^<]*)/i)
    {
        $band = $1;
        $band =~s/\s+$//;
    }
    if($line =~ /<EOR>/i)
    { 
        csvstuff();
    }
}

close($adif);
print "\nTotal of $count contacts with known redditor amateurs\n\n";

sub csvstuff
{
   if (-e $nickfile) 
   {
       open (my $nicks, "<", $nickfile);
       while (<$nicks>)
       {
           chomp;
           my ($csvcall, undef, $userid) = split /,/;
           if (lc $call eq lc $csvcall)
           {
               $count++;
               printf("%-5s%-14s%-25s%-8s%-8s%-10s\n",$count,$call,$userid,$band,$mode,$date);
           }
       }
       close($nicks);
    }
}
