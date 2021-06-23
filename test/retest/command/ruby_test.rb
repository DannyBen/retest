require 'test_helper'

module Retest
  class Command
    class RubyTest < MiniTest::Test
      def setup
        @subject = Ruby.new(all: true, file_system: FakeFS.new([]))
      end

      def test_interface
        assert_respond_to @subject, :run_all
        assert_respond_to @subject, :command
      end

      def test_command
        assert_equal 'ruby <test>', Ruby.new(all: true, file_system: FakeFS.new(['bin/ruby'])).command
        assert_equal 'ruby <test>', Ruby.new(all: true, file_system: FakeFS.new([])).command
        assert_equal 'ruby <test>', Ruby.new(all: false, file_system: FakeFS.new(['bin/ruby'])).command
        assert_equal 'ruby <test>', Ruby.new(all: false, file_system: FakeFS.new([])).command

        assert_equal 'bundle exec ruby <test>', Ruby.new(all: true, file_system: FakeFS.new(['Gemfile.lock', 'bin/ruby'])).command
        assert_equal 'bundle exec ruby <test>', Ruby.new(all: true, file_system: FakeFS.new(['Gemfile.lock'])).command
        assert_equal 'bundle exec ruby <test>', Ruby.new(all: false, file_system: FakeFS.new(['Gemfile.lock', 'bin/ruby'])).command
        assert_equal 'bundle exec ruby <test>', Ruby.new(all: false, file_system: FakeFS.new(['Gemfile.lock'])).command
      end

      def test_run_one_file
        mock = Minitest::Mock.new
        mock.expect :run, true, ['a/file/path.rb']

        @subject.run_all('a/file/path.rb', runner: mock)

        mock.verify
      end

      def test_run_multiple_files
        mock = Minitest::Mock.new
        mock.expect :run, true, ['a/file/path.rb']
        mock.expect :run, true, ['another/file/path.rb']

        @subject.run_all('a/file/path.rb', 'another/file/path.rb', runner: mock)

        mock.verify
      end
    end
  end
end
