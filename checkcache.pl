use File::stat;
use Audio::Scrobbler;
use Data::Dumper;

$timestamp = 1193785905;

$utz_offset = 0; #-2*3600;

$metadatadir='/Users/davidhall/Library/Caches/com.spotify.Client';
$metadatafile=$metadatadir.'/cache-metadata';
$songcachedir=$metadatadir.'/v1';

my %artists = ();
my %albums = ();
my %tracks = ();

$scrob = new Audio::Scrobbler(cfg => {progname => 'tst', progver => 1.0, username=> 'moonhouse', password=>'SECRET', verbose=>1});

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

if($scrob->handshake())
  {
    print "OK";
$lastlength=1;
$lasttimestamp=0;
$lasttrack="";
foreach $track (sort hashValueAscendingNum (keys(%tracks)))
      {
	if($tracks{$track}{'filetimestamp'}>$timestamp)
	  {
	    $thistimestamp=$tracks{$track}{'filetimestamp'};
	    $played=$thistimestamp-$lasttimestamp;
	    $played_percentage= ($played/$lastlength);
	    if(($played_percentage > 0.5 || $played > 240) && $lastlength > 30)
	      {
#		print "\r\nPlayed $lasttrack";
#		print $played_percentage;
		$tracks{$lasttrack}{'played'}=1;
	      }
	    else 
	      {
#		print "\r\nSkipped $lasttrack";
		$tracks{$lasttrack}{'played'}=0;
	      }
	    $lastlength=$tracks{$track}{'length'};
	    $lasttimestamp=$thistimestamp;
	    $lasttrack=$track;
	  }
      }
    if($lastlength>30) 
      {
	$tracks{$lasttrack}{'played'}=1; # last song assumed to be played in its entirety
      }
    else
      {
	$tracks{$lasttrack}{'played'}=0; # last song too short
      }

    $submissions=0;
    foreach $track (sort hashValueAscendingNum (keys(%tracks)))
      {
	if($tracks{$track}{'filetimestamp'}>$timestamp && $tracks{$track}{'played'})
	  {
	    $submission = {
			   title    => $tracks{$track}{'title'},
			   artist   => $artists{$tracks{$track}{'artist'}},
			   'length' => $tracks{$track}{'length'},
			   album    => $albums{$tracks{$track}{'album'}}{'title'},
			   'timestamp' => ($tracks{$track}{'filetimestamp'}+$utz_offset),
	       };
	    print Dumper($submission);
	    $scrob->submit($submission);
	    $submissions++;
	  }
      }
  }

print "\r\n$submissions submissions. $lasttimestamp";

sub hashValueAscendingNum {
   $tracks{$a}{'filetimestamp'} <=> $tracks{$b}{'filetimestamp'};
}
