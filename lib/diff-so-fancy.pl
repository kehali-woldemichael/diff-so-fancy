use utf8;
use open qw(:std :utf8); # http://stackoverflow.com/a/519359
binmode STDOUT,':utf8';

my $change_hunk_indicators    = git_config_boolean("diff-so-fancy.changeHunkIndicators","true");
my $strip_leading_indicators  = git_config_boolean("diff-so-fancy.stripLeadingSymbols","true");
my $mark_empty_lines          = git_config_boolean("diff-so-fancy.markEmptyLines","true");
my $horizontal_color = "";

my $columns_to_remove = 0;

my ($file_1,$file_2);
my $last_file_seen = "";
my $i = 0;
my $in_hunk = 0;
while (my $line = <>) {
	######################################################
	# Pre-process the line before we do any other markup #
	######################################################

	# If the first line of the input is a blank line, skip that
	if ($i == 0 && $line =~ /^\s*$/) {
		next;
	}
	######################
	# End pre-processing #
	######################

	#######################################################################

	####################################################################
	# Look for git index and replace it horizontal line (header later) #
	####################################################################
	if ($line =~ /^${ansi_color_regex}index /) {
		# Print the line color and then the actual line
		$horizontal_color = $1;
		print horizontal_rule($horizontal_color);
	} elsif ($line =~ /^${ansi_color_regex}diff --(git|cc) (.*?)(\s|\e|$)/) {
		$last_file_seen =~ s|^\w/||; # Remove a/ (and handle diff.mnemonicPrefix).
		$in_hunk = 0;
	} elsif (!$in_hunk && $line =~ /^$ansi_color_regex--- (\w\/)?(.+?)(\e|\t|$)/) {
		my $next = <>;
		$next    =~ /^$ansi_color_regex\+\+\+ (\w\/)?(.+?)(\e|\t|$)/;
		if ($file_2 ne "/dev/null") {
			$last_file_seen = $file_2;

		print file_change_string($file_1,$file_2) . "\n";

		# Print out the bottom horizontal line of the header
		print horizontal_rule($horizontal_color);
		$in_hunk = 1;
		my $hunk_header    = $4;
		my $remain         = bleach_text($5);
		$columns_to_remove = (char_count(",",$hunk_header)) - 1;
		print "@ $last_file_seen:$start_line \@${bold}${dim_magenta}${remain}${reset_color}\n";
	################################
	# Look for binary file changes #
	################################
	} elsif ($line =~ /^Binary files (\w\/)?(.+?) and (\w\/)?(.+?) differ/) {
		my $change = file_change_string($2,$4);
		print "$horizontal_color$change (binary)\n";
		print horizontal_rule($horizontal_color);
		my $next = <>;
		# Mark empty line with a red/green box indicating addition/removal
		if ($mark_empty_lines) {
			$line = mark_empty_line($line);
		}

		# Remove the correct number of leading " " or "+" or "-"
		if ($strip_leading_indicators) {
			$line = strip_leading_indicators($line,$columns_to_remove);
		}

	$i++;
######################################################################################################
# End regular code, begin functions
######################################################################################################

# Mark the first char of an empty line
sub mark_empty_line {
	my $line = shift();
	my $reset_color  = "\e\\[0?m";
	my $reset_escape = "\e\[m";
	my $invert_color = "\e\[7m";

	$line =~ s/^($ansi_color_regex)[+-]$reset_color\s*$/$invert_color$1 $reset_escape\n/;

	return $line;
}

# String to boolean
sub boolean {
	my $str = shift();
	$str    = trim($str);

	if ($str eq "" || $str =~ /^(no|false|0)$/i) {
		return 0;
	} else {
		return 1;
}

# Memoize getting the git config
{
	my $static_config;
	sub git_config_raw {
		if ($static_config) {
			# If we already have the config return that
			return $static_config;
		}

		my $cmd = "git config --list";
		my @out = `$cmd`;

		$static_config = \@out;

		return \@out;
	}
# Fetch a textual item from the git config
sub git_config {
	my $search_key    = lc($_[0] // "");
	my $default_value = lc($_[1] // "");
	my $out = git_config_raw();
	# If we're in a unit test, use the default (don't read the users config)
	if (in_unit_test()) {
		return $default_value;
	my $raw = {};
	foreach my $line (@$out) {
		if ($line =~ /=/) {
			my ($key,$value) = split("=",$line,2);
			$value =~ s/\s+$//;
			$raw->{$key} = $value;
		}
	}
	# If we're given a search key return that, else return the hash
	if ($search_key) {
		return $raw->{$search_key} // $default_value;
	} else {
		return $raw;
	}
}
# Fetch a boolean item from the git config
sub git_config_boolean {
	my $search_key    = lc($_[0] // "");
	my $default_value = lc($_[1] // 0); # Default to false
	# If we're in a unit test, use the default (don't read the users config)
	if (in_unit_test()) {
		return $default_value;
	my $result = git_config($search_key,$default_value);
	my $ret    = boolean($result);

	return $ret;
}

# Check if we're inside of BATS
sub in_unit_test {
	if ($ENV{BATS_CWD}) {
		return 1;
	} else {
		return 0;
}
sub get_less_charset {
	my @less_char_vars = ("LESSCHARSET", "LESSCHARDEF", "LC_ALL", "LC_CTYPE", "LANG");
	foreach (@less_char_vars) {
		return $ENV{$_} if defined $ENV{$_};
	}
}
sub should_print_unicode {
	if (-t STDOUT) {
		# Always print unicode chars if we're not piping stuff, e.g. to less(1)
		return 1;
	}
	# Otherwise, assume we're piping to less(1)
	return get_less_charset() =~ /utf-?8/i;
sub get_git_config_hash {
	my $out = git_config_raw();
	foreach my $line (@$out) {
	my $line              = shift(); # Array passed in by reference
	my $columns_to_remove = shift(); # Don't remove any lines by default
	if ($columns_to_remove == 0) {
		return $line; # Nothing to do
	$line =~ s/^(${ansi_color_regex})[ +-]{${columns_to_remove}}/$1/;

	return $line;
# Remove all ANSI codes from a string

# Remove all trailing and leading spaces
sub trim {
	my $s = shift();
	if (!$s) { return ""; }
	$s =~ s/^\s*|\s*$//g;

	return $s;
}

# Print a line of em-dash or line-drawing chars the full width of the screen
sub horizontal_rule {
	my $color = $_[0] || "";
	my $width = `tput cols`;
	my $uname = `uname -s`;

	if ($uname =~ /MINGW32|MSYS/) {
		$width--;
	}

	# em-dash http://www.fileformat.info/info/unicode/char/2014/index.htm
	#my $dash = "\x{2014}";
	# BOX DRAWINGS LIGHT HORIZONTAL http://www.fileformat.info/info/unicode/char/2500/index.htm
	my $dash;
	if (should_print_unicode()) {
		$dash = "\x{2500}";
	} else {
		$dash = "-";
	}

	# Draw the line
	my $ret = $color . ($dash x $width) . "\n";

	return $ret;
}

sub file_change_string {
	my $file_1 = shift();
	my $file_2 = shift();

	# If they're the same it's a modify
	if ($file_1 eq $file_2) {
		return "modified: $file_1";
	# If the first is /dev/null it's a new file
	} elsif ($file_1 eq "/dev/null") {
		return "added: $file_2";
	# If the second is /dev/null it's a deletion
	} elsif ($file_2 eq "/dev/null") {
		return "deleted: $file_1";
	# If the files aren't the same it's a rename
	} elsif ($file_1 ne $file_2) {
		return "renamed: $file_1 to $file_2";
	# Something we haven't thought of yet
	} else {
		return "$file_1 -> $file_2";
	}
}