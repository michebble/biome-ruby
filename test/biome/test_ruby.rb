# frozen_string_literal: true

require 'test_helper'

module Biome
  class TestRuby < Minitest::Spec
    def mock_exe_directory(platform)
      Dir.mktmpdir do |dir|
        FileUtils.mkdir(File.join(dir, platform))
        path = File.join(dir, platform, 'biome')
        FileUtils.touch(path)
        stub_gem_platform_match_gem(true) do
          yield(dir, path)
        end
      end
    end

    def stub_gem_platform_match_gem(value, &block)
      assert_respond_to(Gem::Platform, :match_gem?)
      Gem::Platform.stub(:match_gem?, value, &block)
    end

    def mock_local_biome_install
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'biome')
        FileUtils.touch(path)
        yield(dir, path)
      end
    end

    it '.platform is a string containing just the cpu and os (not the version)' do
      expected = "#{Gem::Platform.local.cpu}-#{Gem::Platform.local.os}"

      assert_equal(expected, Biome::Ruby.platform)
    end

    it '.executable returns the absolute path to the binary' do
      mock_exe_directory('sparc-solaris2.8') do |dir, executable|
        expected = File.expand_path(File.join(dir, 'sparc-solaris2.8', 'biome'))

        assert_equal(expected, executable, 'assert on setup')
        assert_equal(expected, Biome::Ruby.executable(exe_path: dir))
      end
    end

    it ".executable raises UnsupportedPlatformException when we're not on a supported platform" do
      stub_gem_platform_match_gem(false) do # nothing is supported
        assert_raises(Biome::Ruby::UnsupportedPlatformException) do
          Biome::Ruby.executable
        end
      end
    end

    it ".executable raises ExecutableNotFoundException when we can't find the executable we expect" do
      Dir.mktmpdir do |dir| # empty directory
        assert_raises(Biome::Ruby::ExecutableNotFoundException) do
          Biome::Ruby.executable(exe_path: dir)
        end
      end
    end

    it '.executable returns the executable in BIOME_INSTALL_DIR when no packaged binary exists' do
      mock_local_biome_install do |local_install_dir, expected|
        result = nil
        begin
          ENV['BIOME_INSTALL_DIR'] = local_install_dir
          assert_output(nil, /using BIOME_INSTALL_DIR/) do
            result = Biome::Ruby.executable(exe_path: '/does/not/exist')
          end
        ensure
          ENV['BIOME_INSTALL_DIR'] = nil
        end

        assert_equal(expected, result)
      end
    end

    it ".executable returns the executable in BIOME_INSTALL_DIR when we're not on a supported platform" do
      stub_gem_platform_match_gem(false) do # nothing is supported
        mock_local_biome_install do |local_install_dir, expected|
          result = nil
          begin
            ENV['BIOME_INSTALL_DIR'] = local_install_dir
            assert_output(nil, /using BIOME_INSTALL_DIR/) do
              result = Biome::Ruby.executable
            end
          ensure
            ENV['BIOME_INSTALL_DIR'] = nil
          end

          assert_equal(expected, result)
        end
      end
    end

    it '.executable returns the executable in BIOME_INSTALL_DIR even when a packaged binary exists' do
      mock_exe_directory('sparc-solaris2.8') do |dir, _executable|
        mock_local_biome_install do |local_install_dir, expected|
          result = nil
          begin
            ENV['BIOME_INSTALL_DIR'] = local_install_dir
            assert_output(nil, /using BIOME_INSTALL_DIR/) do
              result = Biome::Ruby.executable(exe_path: dir)
            end
          ensure
            ENV['BIOME_INSTALL_DIR'] = nil
          end

          assert_equal(expected, result)
        end
      end
    end

    it '.executable raises ExecutableNotFoundException is BIOME_INSTALL_DIR is set to a nonexistent dir' do
      ENV['BIOME_INSTALL_DIR'] = '/does/not/exist'
      assert_raises(Biome::Ruby::DirectoryNotFoundException) do
        Biome::Ruby.executable
      end
    ensure
      ENV['BIOME_INSTALL_DIR'] = nil
    end
  end
end
