use File::stat;

$some_dir='/Users/davidhall/Library/Caches/com.spotify.Client/v1';

my %fileHash = ();

opendir(DIR, $some_dir) || die "can't opendir $some_dir: $!";
@dots = readdir(DIR);
closedir DIR;

foreach $file (@dots) {
  $sb = stat($some_dir.'/'.$file);
  $fileHash{$file}=$sb->atime;
}

@test = (sort { $fileHash{$a} <=> $fileHash{$b} } keys %fileHash);

print $test[-3];
print scalar localtime $fileHash{$test[-3]};

#foreach my $key (sort { $fileHash{$a} <=> $fileHash{$b} } keys %fileHash) {
#    printf "%s: %s\n", $key, scalar localtime $fileHash{$key};
#  }

#   $sb = stat($filename);
#   printf "File is %s, size is %s, perm %04o, atime %s\n",
#	$filename, $sb->size, $sb->mode & 07777,
#	scalar localtime $sb->atime;
