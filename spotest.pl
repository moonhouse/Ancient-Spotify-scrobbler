use File::stat;
use Data::Dumper;

$timestamp = 1193785905;

$utz_offset = 0; #-2*3600;

$metadatadir='/Users/davidhall/Library/Caches/com.spotify.Client';
$metadatafile=$metadatadir.'/cache-metadata';
$songcachedir=$metadatadir.'/v1';

my %artists = ();
my %albums = ();
my %tracks = ();


open(MYINPUTFILE,"<:utf8", "$metadatafile");
while(<MYINPUTFILE>)
  {
    my($line) = $_;
    
    @fields = split(chr(1),$line);
    $num_of_fields=@fields;
    if($num_of_fields==2)
      {
	# artist_uid|artist
	$artists{$fields[0]}=$fields[1];
      }
    elsif($num_of_fields==5)
      {
	# album_uid|title|unknown|unknown|year|unknown
	$albums{$fields[0]}{'title'}=$fields[1];
	$albums{$fields[0]}{'year'}=$fields[4];
	#print join("|",@fields),"\n";
      }
    elsif($num_of_fields==8)
      {
	# unknown|title|artist_uid|filename|length|trackno|album_uid|timestamp
	$tracks{$fields[0]}{'title'}=$fields[1];
	$tracks{$fields[0]}{'artist'}=$fields[2];
	$tracks{$fields[0]}{'length'}=$fields[4];
	$tracks{$fields[0]}{'trackno'}=$fields[5];
	$tracks{$fields[0]}{'album'}=$fields[6];
	$tracks{$fields[0]}{'timestamp'}=$fields[7];
	if (-e "$songcachedir/".$fields[3].".file")
	  { 
	    #  print "File exists";
	    $sb = stat("$songcachedir/".$fields[3].".file");
	    $tracks{$fields[0]}{'filetimestamp'}=$sb->atime;
	  }
#	print "$num_of_fields: " .join("|",@fields),"\n";
      }
    else
      {
		print "$num_of_fields: " .join("|",@fields),"\n";
      }
  }


foreach $track (sort hashValueAscendingNum (keys(%tracks)))
      {
print $tracks{$track}{'title'};
print ": ";
print scalar localtime $tracks{$track}{'timestamp'};
print ", ";
print scalar localtime $tracks{$track}{'filetimestamp'};
print "\n";

  }

sub hashValueAscendingNum {
   $tracks{$a}{'filetimestamp'} <=> $tracks{$b}{'filetimestamp'};
}
