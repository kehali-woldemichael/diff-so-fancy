	assert_output --partial 'circle.yml changed file mode from 100644 to 100755'
@test "Hunk formatting: @@@ -A,B -C,D +E,F @@@" {
	# stderr forced into output
	output=$( load_fixture "complex-hunks" | $diff_so_fancy 2>&1 )
	assert_output --partial '@ header_clean.pl:107 @'
    refute_output --partial 'Use of uninitialized value'
}
