#!/usr/bin/env perl
# make sure to change your user agent:
# http://www.howtogeek.com/113439/how-to-change-your-browsers-user-agent-without-installing-any-extensions/

# Get the script's path and use that to find dict.txt
use File::Basename;
use Cwd 'abs_path';
my $path = dirname(abs_path($0));

my $quiet = 1;

# Autoflush the buffer
$| = 1;

##########################
### GENERATE CONSTANTS ###
##########################
my @pc_user_agents = (
	"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36", # Chrome
	"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:47.0) Gecko/20100101 Firefox/47.0", # Firefox
	"Mozilla/5.0 (Macintosh; ARM Mac OS X) AppleWebKit/538.15 (KHTML, like Gecko) Safari/538.15 Version/6.0 Raspbian/8.0 (1:3.8.2.0-0rpi27rpi1g) Epiphany/3.8.2", # Epiphany
	"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41" # Opera
);

my @mobile_user_agents = (
	"Mozilla/5.0 (Linux; Android 5.1.1; Nexus 5 Build/LMY48B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.93 Mobile Safari/537.36", # Nexus 5 Chrome
	"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_2 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/51.0.2704.104 Mobile/13F69 Safari/601.1.46", # iPhone Chrome
	"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13F69 Safari/601.1" # iPhone Safari
);

my $length_of_pc_user_agents = (scalar @pc_user_agents);
my $pc_user_agent = $pc_user_agents[generate_random_integer(0, $length_of_pc_user_agents)];
my $length_of_mobile_user_agents = (scalar @mobile_user_agents);
my $mobile_user_agent = $mobile_user_agents[generate_random_integer(0, $length_of_mobile_user_agents)];

my $minimum_number_of_pc_searches = 10;
my $maximum_number_of_pc_searches = 35;
my $minimum_number_of_mobile_searches = 10;
my $maximum_number_of_mobile_searches = 25;
my $minimum_startup_delay = 0*60*60;
my $maximum_startup_delay = 4*60*60;

my $number_of_pc_searches = generate_random_integer($minimum_number_of_pc_searches, $maximum_number_of_pc_searches);
my $number_of_mobile_searches = generate_random_integer($minimum_number_of_mobile_searches, $maximum_number_of_mobile_searches);
my $startup_delay = generate_random_integer($minimum_startup_delay, $maximum_startup_delay);
my $minimum_delay_between_queries = 5*60;
my $maximum_delay_between_queries = 20*60;
my $browser = "";
my $proxy = "";
my $user_agent = "";

$maximum_process_time_hours = (($maximum_number_of_pc_searches + $maximum_number_of_mobile_searches) * $maximum_delay_between_queries + $maximum_startup_delay) / 60 / 60;
$minimum_process_time_hours = (($minimum_number_of_pc_searches + $minimum_number_of_mobile_searches) * $minimum_delay_between_queries + $minimum_startup_delay) / 60 / 60;

print "Maximum process time is $maximum_process_time_hours hours.\n";
print "Minimum process time is $minimum_process_time_hours hours.\n";

########################
### CHECK THE SYSTEM ###
########################
check_system();

system("touch ~/binger/start.touch");
print "number_of_pc_searches = $number_of_pc_searches\n";
print "number_of_mobile_searches = $number_of_mobile_searches\n";
print "startup_delay = $startup_delay seconds\n";
print "sleeping for $startup_delay seconds\n\n";
sleep $startup_delay;

##########
### PC ###
##########
$user_agent = $pc_user_agent;

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
$user_agent = $mobile_user_agent;

for (my $count = 1; $count <= $number_of_mobile_searches; $count++) {
	wait_a_bit();
	my $number_of_words = generate_random_integer(2, 5);
	my @word_array = generate_word_array($number_of_words);
	query_bing(@word_array);
	print "submitted query #$count of $number_of_mobile_searches\n";
}

# close all browsers
wait_a_bit();
kill_browsers();
# clear the user agent so it goes back to default?
print "Clear the user agent so it goes back to default\n";
system('dbus-launch gsettings set org.gnome.Epiphany user-agent ""');
#system('dbus-launch gsettings set org.gnome.Epiphany user-agent "Mozilla/5.0 (Macintosh; ARM Mac OS X) AppleWebKit/538.15 (KHTML, like Gecko) Safari/538.15 Version/6.0 Raspbian/8.0 (1:3.8.2.0-0rpi27rpi1g) Epiphany/3.8.2"');
print "Touching the finish file\n";
system("touch ~/binger/finish.touch");
print "End of script.\n";

###################
### SUBROUTINES ###
###################

sub kill_browsers {
	print "trying to kill the browser\n";
	system("pkill epiphany");
	system("pkill epiphany-browser");
	system("pkill chromium");
	system("pkill chromium-browser");
}

sub build_command {
	print "\nbuild_command\n";
	my $url = shift;
	print "browser = $browser\n";
	print "user_agent = $user_agent\n";
	print "proxy = $proxy\n";
	print "url = $url\n";
	my $command = "";
	if ($browser =~ "chromium-browser") {
		$command = "DISPLAY=:0 " . $browser;
		if (length($proxy) > 0) {
			$command .= ' ' . "--proxy-server=\"$proxy\"";
		}
		$command .= ' ' . "--user-agent=\"$user_agent\"";
	} elsif ($browser =~ "epiphany") {
		$command = "dbus-launch gsettings set org.gnome.Epiphany user-agent \"$user_agent\"";
		$command .= " && ";
		$command .= "DISPLAY=:0 " . $browser;
	}
	$command .= ' ' . "\"$url\"";
	if ($quiet) {
		$command .= " >/dev/null 2>&1";
	}
	print "command = $command\n";
	return $command;
}

sub check_system {
	my $epiphany_check = `which epiphany`;
	print "epiphany_check = $epiphany_check\n";
	my $chromium_check = `which chromium-browser`;
	print "chromium_check = $chromium_check\n";
	if (`which epiphany` =~ "epiphany") {
		print "found epiphany!\n";
		$browser = "epiphany";
	} elsif (`which chromium-browser` =~ "chromium-browser") {
		print "found chrome!\n";
		$browser = "chromium-browser";
	} else {
		print "=================================================\n";
		print "Epiphany needs to be installed. Run this command:\n";
		print "sudo apt-get install epiphany-browser -y\n";
		print "                   --- OR ---                    \n";
		print "Chromium needs to be installed. Run this command:\n";
		print "sudo apt-get install chromium-browser -y\n";
		print "=================================================\n";
		exit;
	}
	# ADD A CHECK TO SEE IF X IS RUNNING HERE
	#my $x_server_check = `pidof X && echo "yup X server is running"`;
	#print "x_server_check = $x_server_check\n";
	$proxy = $ENV{http_proxy};
	print "proxy = $proxy\n";
}

sub wait_a_bit {
	my $seconds = generate_random_integer($minimum_delay_between_queries, $maximum_delay_between_queries);
	print "sleeping for $seconds seconds\n\n";
	sleep $seconds;
}

sub query_bing {
	print "query_bing start\n";
	my @word_list = ();
	foreach (@_) { push(@word_list, $_); } 
	print "word_list = '@word_list'\n";
	my $url = "https://www.bing.com/search?setmkt=en-US&q=" . join("+", @word_list);
	print "url = '$url'\n";
	my $command = build_command($url);
	kill_browsers();
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

#chromium proxy server:
#https://www.chromium.org/developers/design-documents/network-settings..