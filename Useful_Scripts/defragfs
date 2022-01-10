#!/usr/bin/perl
# defragfs.pl -- Measurement and Report and Defrag fs/file fragmentation

# CanHao Xu <xucanhao@gmail.com>, 2007
# John Robson <john.robson@usp.br>, 2011

# Using:	$ sudo ./defragfs / -af
# Help: 	$ ./defragfs / -h

print ("defragfs 1.1.1, Released under GPLv3 by John Robson <john.robson\@usp.br>, March 2011 (help: \$ defragfs / -h)\n\n");

($DIR, $ARG) = @ARGV;

if($ARG =~ m/h/) {	die("GNU/Linux file systems rarely fragmented files. The file system always allocates more space to write a file, but sometimes the file size grows so that space becomes insufficient and the file is fragmented, but even so the file system fragments the file efficiently.

Using defragfs:

\$ sudo ./defragfs <partition or directory>\te.g. \$ sudo ./defragfs /usr/

(or copy to /usr/bin/ and use in anywhere) \t\$ sudo cp -af defragfs /usr/bin/\te.g. \$ sudo defragfs /home/
(perhaps you may need to give execute permissions: \$ sudo chmod +x /usr/bin/defragfs)

Options:

-a\tAutomatically defrag (configure: \$max_fragrate and \$max_avgfrags according to your preference).
	Use this in your crontab.\te.g. sudo crontab -e\t(and add this line)\t0 0 1 */2 * defragfs / -a
	
-f\tForce defrag if there is at least one fragmented file.

-h\tDisplay this Help.

Examples of using:

\$ sudo defragfs /\t\tAnalyzes 'root', displays statistics and whether or not you need to defragment.

\$ sudo defragfs /home/ -a\tAnalyzes 'home', displays statistics and whether or not you need to defragment, if necessary, automatically defragments and exits.

\$ sudo defragfs /usr/ -f\tAnalyzes 'usr', displays statistics and waiting for your permission to defragment.

\$ sudo defragfs /home/user/.VirtualBox/HardDisks/ -af\tAnalyzes 'this directory', displays statistics, automatically defragments and exits.

Note 1: This program was tested on several different machines and also encrypted HOME partitions; worked without any problem.

Note 2: This program simply copies a fragmented file, keeping all its attributes unchanged (cp -a file) and verifying that the file has not changed during the process. The *file system performs the defragmentation process*. Not all files can be defragmented.

Note 3: If the directory you specified contains too much files (e.g. tens of thousands), it could take you several minutes on analysis, you may disturb it by CTRL+C at anytime. And BTW: the program is CURRENTLY not accurate on Reiser4 due to its default tailing policy (you may see a high fragment rate before and even after)

Note 4: If you want to see how many fragments the file contains: \$ sudo filefrag -sv file

If the file is large and has more than 10 fragments, calculate the loss of performance:
\t1) \$ sudo cp -af file file.bak\t# copy the file, the copy usually has no fragments or very little
\t2) \$ sudo filefrag -sv file.bak\t# check if the copy is less fragmented
\t3) calculate the time to read the copy and the original:
\t\ttime cat file.bak > /dev/null
\t\ttime cat file > /dev/null

* Generally a very fragmented file takes much longer to read and less fragmented file is much faster. If the file is small (less than 100 mb) you may not notice the loss of performance because of *disk caching*, the ideal is to test large files over 300 mb or 1 gb.

I hope you enjoy this program.
Thanks, John.
"); }

if (!(-e $DIR) || !(-d $DIR)) { die "You must specify a correct directory name!
"; }

my $AUTO = 0;
my $FORCE = 0;

if($ARG =~ m/a/) { $AUTO = 1; }
if($ARG =~ m/f/) { $FORCE = 1; }

if (($DIR eq "") || ($DIR =~ m/-/)) { die "Usage: defragfs.pl DIRECTORY [-af], -af means force automatic defragmentation
"; }

start:
print ("Analysis in progress...\n\n");

my $files = 0; # number of files
my $fragments = 0; # number of fragment before defrag
my $fragfiles = 0; # number of fragmented files before defrag
my $TMP_filefrag_1 = "/tmp/frags-result-tmp";
my $TMP_filefrag_2 = "/tmp/frags-result";
my $TMP_defrag_filelist_1 = "/tmp/defrag-filelist-tmp";
my $TMP_defrag_filelist_2 = "/tmp/defrag-filelist";
my $max_fragrate = 1; # max "File Fragmentation Rate" used to determine whether worth defrag.
my $max_avgfrags = 1.1; # max "Avg File Fragments" used to determine whether worth defrag.
my $default_defrag_ratio; # default defragmentation ratio in percentage
my $max_display_num = 10; # display how much files in report
my $total_defrag_files = 0; # which files to be defrag, determined after user input the ratio
my $max_tries = 1; # max "Max Tries" used to determine max attempts to defrag a file after first attempt.

system("rm -f $TMP_filefrag_1");
system("rm -f $TMP_filefrag_2");
system("rm -f $TMP_defrag_filelist_1");
system("rm -f $TMP_defrag_filelist_2");

my $progress = 0;
open (FILES, "find \"" . $DIR . "\" -xdev -type f |");
while (defined (my $file = <FILES>)) {
  $file =~ s/!/\\!/g;
  $file =~ s/#/\\#/g;
  $file =~ s/&/\\&/g;
  $file =~ s/>/\\>/g;
  $file =~ s/</\\</g;
  $file =~ s/\$/\\\$/g;
  $file =~ s/\(/\\\(/g;
  $file =~ s/\)/\\\)/g;
  $file =~ s/\|/\\\|/g;
  $file =~ s/'/\\'/g;
  $file =~ s/ /\\ /g;
  open (FRAG, "filefrag $file |");
  my $res = <FRAG>;
  if ($res =~ m/.*:\s+(\d+) extents? found/) {
    my $fragment = $1;
    if ($fragment eq 0) { $fragment = 1; }
    $fragments+=$fragment;
    if ($fragment > 1) {
      system("echo -n \"$res\" >> $TMP_filefrag_1");
      $fragfiles++;
     }
    $files++;
  }
  close (FRAG);
  if (($progress++ % 1000) eq 0) { print "."; }
}
close (FILES);

if ($files eq 0) {
  print ("The selected directory contains no file!\n");
  exit;
}
system("sort $TMP_filefrag_1 -g -t : -k 2 -r | sed \"/^\$/d\" > $TMP_filefrag_2");

print ("\n\nStatistics for $DIR\n\n");
print ("Total Files:\t\t\t" . $files . "\n");
print ("Total Fragmented Files:\t\t" . $fragfiles . "\n");
print ("Total Fragments:\t\t" . ($fragments - $files) . "\n");
if ($fragfiles > 0) { print ("Fragments per Fragmented File:\t" . ($fragments - $files) / $fragfiles . "\n\n"); }
if ($files > 0) { print ("File Fragmentation Rate:\t" . ($fragfiles / $files) * 100 . " %\n"); }
if ($files > 0) { print ("Avg File Fragments (1 is best):\t" . $fragments / $files . "\n"); }

if ($fragfiles > 0) {
  if ($max_display_num > $fragfiles) { $max_display_num = $fragfiles; }
  print ("\nMost Fragmented Files(for details see $TMP_filefrag_2):\n");
  system("head $TMP_filefrag_2 -n $max_display_num");
} else {
  print ("\nYou do not need a defragmentation!\n");
  exit;
}

$default_defrag_ratio = ($files eq 1) ? 100 : ($fragfiles / $files) * 100;

if (((($fragfiles / $files) * 100) > $max_fragrate) || (($fragments / $files) > $max_avgfrags) || ($FORCE)) {
  print ("\nYou need a defragmentation or Your are using -f parameter!\n");
} else {
  print ("\nYou do not need a defragmentation!\n");
  exit;
}

defrag:
print ("\nPlease specify the percentage of files should be defrag (1-100) [$default_defrag_ratio] or hit Enter.");

if ($AUTO) { $defrag_ratio = "" }
else { $defrag_ratio = <STDIN>; }
chop($defrag_ratio);

if (!($defrag_ratio eq "") && (($defrag_ratio < 0) || ($defrag_ratio > 100))) {
  print ("Error percentage numbers, please re-enter!\n");
  goto defrag;
} else {
  $total_defrag_files = ($defrag_ratio eq "") ? $fragfiles : int($defrag_ratio * $files / 100);
}

print ("\nPreparing defragmentation, please wait...\n");

print ("\nFiles to be defragmented: " . $total_defrag_files . "\n\n");
if ($total_defrag_files eq 0) { exit; }
system("head $TMP_filefrag_2 -n $total_defrag_files > $TMP_defrag_filelist_1");

open (TMPFRAGLIST, "$TMP_defrag_filelist_1");
while (<TMPFRAGLIST>) {
  m/(.*):\s+(\d+) extents? found/;
  my $filename = $1;
  system("echo \"$1\" >> $TMP_defrag_filelist_2");
}

open (GETSIZE, "$TMP_defrag_filelist_2");
my $max = 0;
while (<GETSIZE>) {
  s/(.*)\n/$1/;
  $size = -s "$_";
  if ($size > $max) { $max = $size; }
}

print ("You need AT LEAST " . sprintf("%.3f", $max / 1048576) . " Megabytes temporarily used for defragmentation (at the directory where you specified), continue (Y/N)? [Y] ");
if ($AUTO) { $confirm = "" }
else { $confirm = <STDIN>; }
chop($confirm);

if (($confirm eq "y") || ($confirm eq "Y") || ($confirm eq "")) {
  print ("\nOK, please drink a cup of tea and wait...\n");
  print ("\nFile Number - File Name (Size Mb) [actual extents] - extents after defrag attempt\n");
  my $actual_file = $total_defrag_files;
  open (DEFRAG, "$TMP_defrag_filelist_2");
  
  while (<DEFRAG>) {
    s/(.*)\n/$1/;
    $from = $_;
    s/(.*)/$1.ft/;
    $to = $_;
    
    my $i_file = $actual_file;
    my $i_tries = 0;
    while ($i_tries++ < $max_tries) {
      my $fragment_from = 0;
      my $fragment_to = 0;
      my $res;

      open (FRAG, "-|", "filefrag", $from);
      $res = <FRAG>;
      if ($res =~ m/.*:\s+(\d+) extents? found/) { $fragment_from = $1; }
      
      if ($i_file eq $actual_file) {
        my $size = sprintf("%.3f", (stat($from))[7] / 1048576);
        print "\n$actual_file - $from ($size) [$fragment_from] - ";
        $actual_file--;
      }

      my $mtime1 = (stat($from))[9];
      system("sync");
      system("cp -af \"$from\" \"$to\" 2>/dev/null");
      #system("rsync -aEHAX --devices --specials \"$from\" \"$to\" 2>/dev/null");
      system("sync");
      my $mtime2 = (stat($from))[9];

	    if ($mtime1 != $mtime2) { # check the file hasn't been altered since we copied it
  	    system("rm -f \"$to\"");
        print "! ";
      } else {
        open (FRAG, "-|", "filefrag", $to);
        $res = <FRAG>;
        if ($res =~ m/.*:\s+(\d+) extents? found/) { $fragment_to = $1; }

        if ($fragment_to <= $fragment_from) { # <= not just <
          system("mv -f \"$to\" \"$from\" 2>/dev/null"); 
          print "$fragment_to ";
          if ($fragment_to eq 1) { last; }
          if ($fragment_to eq $fragment_from) { $i_tries++; }
          if ($fragment_to < $fragment_from) { $i_tries--; }
        } else {  
          system("rm -f \"$to\"");
          print "$fragment_from ";
        }
      }
      system("sync");
    }
  }

  system("sync");
  print ("\n\nDone!\n\n");
  
  if ($AUTO) { exit; }
  else { goto start; }
} else {
  exit;
}

