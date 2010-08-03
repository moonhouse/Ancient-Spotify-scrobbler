use File::stat;

$metadatadir='/Users/davidhall/Library/Caches/com.spotify.Client';
$metadatafile=$metadatadir.'/cache-metadata';
$songcachedir=$metadatadir.'/v1';
$timestamp = 1183662087;
$latesttimestamp=0;

my %albums = ();
my %tracks = ();

open(MYINPUTFILE,"<:utf8", "$metadatafile");
while(<MYINPUTFILE>)
  {
    my($line) = $_;
    
    @fields = split(chr(1),$line);
    $num_of_fields=@fields;
    
    if($num_of_fields==9)
      {
	($hash1,$songtitle,$artist,$uid_artist,$uid_song,$length,$trackno,$uid_album,$datetime) = @fields;

if (-e "$songcachedir/$uid_song.file")
{ 
#  print "File exists";
  $sb = stat("$songcachedir/$uid_song.file");
  $filetime=$sb->atime;
}
else {$filetime=$datetime;}
$tracks{$uid_song} = {title => $songtitle, artist => $artist, artist_uid => $uid_artist, length => $length, trackno => $trackno, album_uid => $uid_album, played => $datetime, hash1 => $hash1, filetime => $filetime};
if($datetime > $timestamp)
  {
	printf "%d. %s - %s (from %s) (%d.%d) %s %d\n",$trackno,$artist, $songtitle, $albums{$uid_album}{'albumtitle'} ,$length/60,$length%60, scalar localtime $datetime, $datetime;
# $datetime, $hash1, $uid_artist, $uid_song, $uid_album;
if($datetime > $latesttimestamp)
  {
    $latesttimestamp = $datetime;
  }
      }
}
    elsif ($num_of_fields==6) 
      {
	($uid_album, $albumtitle, $hash3, $artist, $year, $description) = @fields;
	printf "%s - %s (%d): %s. %s\n",$artist, $albumtitle, $year, $description, $hash3;
	$albums{$uid_album}{'albumtitle'}=$albumtitle;
      }
    
  }
print "Latest timestamp: $latesttimestamp";

foreach $key (sort hashValueAscendingNum (keys(%tracks))) {
   printf "\t\t%s\t\t%s\t\t%s\t\t%s\n", scalar localtime $tracks{$key}{'filetime'},$tracks{$key}{'title'};
}

sub hashValueAscendingNum {
   $tracks{$a}{'filetime'} <=> $tracks{$b}{'filetime'};
}

