#!/usr/bin/env perl
# make sure to change your user agent:
# http://www.howtogeek.com/113439/how-to-change-your-browsers-user-agent-without-installing-any-extensions/

# Get the script's path and use that to find dict.txt
use File::Basename;
use Cwd 'abs_path';
my $path = dirname(abs_path($0));

# Autoflush the buffer
$| = 1;

########################
### CHECK THE SYSTEM ###
########################
check_system();

##########################
### GENERATE CONSTANTS ###
##########################
my $number_of_pc_searches = generate_random_integer(30, 40);
my $number_of_mobile_searches = generate_random_integer(20, 30);
my $startup_delay = generate_random_integer(0, 3600);

system("touch ~/binger/start.touch");
my $seconds = generate_random_integer(1, 3);
print "number_of_pc_searches = $number_of_pc_searches\n";
print "number_of_mobile_searches = $number_of_mobile_searches\n";
print "startup_delay = $startup_delay seconds\n";
print "sleeping for $startup_delay seconds\n";
sleep $startup_delay;

##########
### PC ###
##########
# Mozilla/5.0 (Macintosh; ARM Mac OS X) AppleWebKit/538.15 (KHTML, like Gecko) Safari/538.15 Version/6.0 Raspbian/8.0 (1:3.8.2.0-0rpi27rpi1g) Epiphany/3.8.2
system('dbus-launch gsettings set org.gnome.Epiphany user-agent "Mozilla/5.0 (Macintosh; ARM Mac OS X) AppleWebKit/538.15 (KHTML, like Gecko) Safari/538.15 Version/6.0 Raspbian/8.0 (1:3.8.2.0-0rpi27rpi1g) Epiphany/3.8.2"');


for (my $count = 1; $count <= $number_of_pc_searches; $count++) {
	wait_a_bit();
	my $number_of_words = generate_random_integer(2, 5);
	my @word_array = generate_word_array($number_of_words);
	query_bing(@word_array);
	print "submitted query #$count of $number_of_pc_searches\n";
}

##############
### Mobile ###
##############
# Mozilla/5.0 (Linux; Android 5.1.1; Nexus 5 Build/LMY48B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.93 Mobile Safari/537.36
system('dbus-launch gsettings set org.gnome.Epiphany user-agent "Mozilla/5.0 (Linux; Android 5.1.1; Nexus 5 Build/LMY48B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.93 Mobile Safari/537.36"');

for (my $count = 1; $count <= $number_of_mobile_searches; $count++) {
	wait_a_bit();
	my $number_of_words = generate_random_integer(2, 5);
	my @word_array = generate_word_array($number_of_words);
	query_bing(@word_array);
	print "submitted query #$count of $number_of_mobile_searches\n";
}

system("touch ~/binger/finish.touch");

###################
### SUBROUTINES ###
###################

sub check_system {
	my $epiphany_check = `which epiphany`;
	print "epiphany_check = $epiphany_check\n";
	if (`which epiphany` !~ "epiphany") {
		print "Epiphany needs to be installed. Run this command:\n";
		print "sudo apt-get install epiphany -y\n";
		exit;
	}
	my $x_server_check = `pidof X && echo "yup X server is running"`;
	print "x_server_check = $x_server_check\n";
	exit;
}

sub wait_a_bit {
	my $seconds = generate_random_integer(30, 60);
	print "sleeping for $seconds seconds\n";
	sleep $seconds;
}

sub query_bing {
	print "query_bing start\n";
	my @word_list = ();
	foreach (@_) { push(@word_list, $_); } 
	print "word_list = '@word_list'\n";
	my $url = "https://www.bing.com/search?setmkt=en-US&q=" . join("+", @word_list);
	print "url = '$url'\n";
	my $command = 'DISPLAY=:0 epiphany';
	$command .= ' ';
	$command .= '"' . $url . '"';
	print "trying to kill the browser\n";
	system("pkill epiphany-browse");
	print "command = '$command'\n";
	system("$command &");
	print "query_bing complete\n";
}

sub generate_random_integer {
	my $minimum = shift;
	my $maximum = shift;
	my $range = $maximum - $minimum;
	return int(rand($range)) + $minimum;
}

sub generate_word_array {
	my $number_of_words = shift;
	my @word_list = ();
	for (my $i = 0; $i < $number_of_words; $i++) {
		push(@word_list, generate_random_word());
	}
	return @word_list;
}

sub generate_random_word {
	open DICT, "<$path\/dict.txt" or die $!;
	my @lines = <DICT>;
	my $max = scalar(@lines) - 1;
	my $word;
	while ((length($word) == 0) || ($word =~ m/\'/)) {
		my $word_number = generate_random_integer(0, $max);
		$word = $lines[$word_number];
		chomp($word);
	}
	print "word = $word\n";
	return $word;
}
