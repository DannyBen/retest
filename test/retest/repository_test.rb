require 'test_helper'
require_relative 'repository/multiple_test_files_with_user_input.rb'

module Retest
  class RepositoryTest < MiniTest::Test
    def setup
      @subject = Repository.new
    end

    def test_default_files
      assert_equal Dir.glob('**/*') - Dir.glob('{tmp,node_modules}/**/*'), @subject.files
    end

    def test_find_test
      @subject.files = %w(
        test/songs/99bottles.txt
        test/bottles_test.rb
        program.rb
        README.md
        lib/bottles.rb
        Gemfile
        Gemfile.lock
      )

      assert_equal 'test/bottles_test.rb',
        @subject.find_test('99bottles_ruby/lib/bottles.rb')
    end

    def test_cache
      mock_cache = {}
      expected = { "file_path.rb" => "file_path_test.rb" }

      Repository.new(files: ['file_path_test.rb'], cache: mock_cache)
        .find_test('file_path.rb')

      assert_equal expected, mock_cache
    end

    def test_find_test_similar_files
      @subject.files = %w(
        test/models/schedule/holdings_test.rb
        test/models/taxation/holdings_test.rb
        test/models/holdings_test.rb
        test/models/performance/holdings_test.rb
        test/models/valuation/holdings_test.rb
        test/lib/csv_report/holdings_test.rb
      )

      expected = <<~EXPECTED
        We found few tests matching:
        [0] - test/models/valuation/holdings_test.rb
        [1] - test/models/taxation/holdings_test.rb
        [2] - test/models/schedule/holdings_test.rb
        [3] - test/models/performance/holdings_test.rb
        [4] - test/models/holdings_test.rb

        Which file do you want to use?
        Enter the file number now:
      EXPECTED

      @subject.input_stream = StringIO.new("1\n")

      out, _ = capture_subprocess_io { @subject.find_test('app/models/valuation/holdings.rb') }

      assert_match expected, out
    end
  end
end