my $git_strip_prefix           = git_config_boolean("diff.noprefix","false");
		if ($git_strip_prefix) {
			my $file_dir = $4 || "";
			$file_1 = $file_dir . $5;
		} else {
			$file_1 = $5;
		}
		if ($git_strip_prefix) {
			my $file_dir = $4 || "";
			$file_2 = $file_dir . $5;
		} else {
			$file_2 = $5;
		}

		$in_hunk        = 1;
		my $hunk_header = $4;
		my $remain      = bleach_text($5);

		# The number of colums to remove (1 or 2) is based on how many commas in the hunk header
		$columns_to_remove   = (char_count(",",$hunk_header)) - 1;
		# On single line removes there is NO comma in the hunk so we force one
		$columns_to_remove ||= 1;
		return boolean($default_value);
	if ($line_num == 0 && $diff_context == 0) {
		return 1;
	}
