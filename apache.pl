#!/bin/usr/perl/
#Programmer: Kevin Law
#>Implying GNU license
#Version: 0.8

use Carp;
my $max_records = '10'; #change for max records. 0 is no limit
 open (FH, '<', "/var/log/httpd/access_log")
  		or die "error, Cannot open $file";

   
while (<FH>) {
	$line = $_;
	  
	next if $line =~ m/^\s*$/;
	next if $line =~ m/^\s*#/; 
	chomp($line);
  


  #
   if ($line =~ m/^(\S+) (\S+) (\S+) \[([^:]+):(\d+:\d+:\d+) ([^\]]+)\] \"(\S+) (.*?) (\S+)\" (\S+) (\S+) (\".*?\") (\".*?\")$/ ) {
			$ip			= "$1";
			$dash		= "$2";
			$dash2		= "$3";
			$date		= "$4";
			$time		= "$5"; 
			$result		= "$6";  
			$method		= "$7";
			$url		= "$8";
			$what2		= "$9";
			$result     = "$10";
			$what3		= "$11";
			$referrer	= "$12";
			$useragent	= "$13";
                   
                    
					#Search engines look for robots.txt
					if ( $url =~ m!^(/robots.txt)! ) {     
						$search++;
					} 
					#Scanners generaly hit a lot of pages that do not exist
					if ( $result == "404") {
					$scanners++;
					}
			
#"$ip\t$date\t$time\t$method\t$url\t$result\t$useragent\n"; uncomment for debugging purposes. It will just spit out the parsed log

#add stats to our counters
$hits_by_day_for{$date}++;
$hits_by_cip_for{$ip}++;
$hits_by_url_for{$url}++;
$hits_by_result_for{$result}++;
$hits_by_robot_for{$useragent}++      if ( $url =~ m!^/robots.txt! );
$hits_by_scanner_for{"$result $url"}++ if ( $result == "404" );
			
			
					
			}
	else {
                  push(@Unparsedarray, ($line)); 
                 
            }




} #end while

close (FH);

#         Hash Reference          "Name"          "Top N" to show
Display(\%hits_by_day_for,      'By Date',        $max_records);
Display(\%hits_by_cip_for,      'By CIP',         $max_records);
Display(\%hits_by_result_for,   'By Result',      $max_records);
Display(\%hits_by_url_for,      'By URL',         $max_records);
Display(\%hits_by_robot_for,    'By Robot',   $max_records);
Display(\%hits_by_scanner_for,  'By Scanner_404', $max_records);

print "Number of times a search engine visted site: $search\n";
print "Number of Scans (most likely false alarms): $scanners\n";

#print unparsed logs. useful for weird stuff that didn't match the regex
if ( @unparsed ) {
    print STDERR "\n";
    foreach my $unparsed ( @unparsed ) {
        print STDERR "unparsed: $unparsed\n";
    }
}

######## Subs ########

# Returns when $max_records recahed
sub Display {
    @_ == 3 or carp 'Sub Display(\%hash, "name", $max_records)';
    my ( $hash_ref, $name, $max_records, ) = @_;
    my $counter = 0;

    print STDERR "\nCount\t$name\n";
    foreach my $hit (sort { $$hash_ref{$b} <=> $$hash_ref{$a} } keys %{$hash_ref}) {
        print STDERR $$hash_ref{$hit} . "\t$hit\n";
        $counter++;
        return if ( $max_records and $counter >= $max_records );
    }
} # end of sub Display
