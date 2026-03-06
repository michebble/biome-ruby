# frozen_string_literal: true

require_relative 'ruby/version'
require_relative 'ruby/upstream'

module Biome
  module Ruby
    DEFAULT_DIR = File.expand_path(File.join(__dir__, '..', '..', 'exe'))
    GEM_NAME = 'biome-ruby'

    # raised when the host platform is not supported by upstream biome's binary releases
    class UnsupportedPlatformException < StandardError
    end

    # raised when the biome executable could not be found where we expected it to be
    class ExecutableNotFoundException < StandardError
    end

    # raised when BIOME_INSTALL_DIR does not exist
    class DirectoryNotFoundException < StandardError
    end

    class << self
      def platform
        %i[cpu os].map { |m| Gem::Platform.local.send(m) }.join('-')
      end

      def executable(exe_path: DEFAULT_DIR)
        biome_install_dir = ENV.fetch('BIOME_INSTALL_DIR', nil)
        if biome_install_dir
          raise DirectoryNotFoundException, <<~MESSAGE unless File.directory?(biome_install_dir)
            BIOME_INSTALL_DIR is set to #{biome_install_dir}, but that directory does not exist.
          MESSAGE

          warn "NOTE: using BIOME_INSTALL_DIR to find biome executable: #{biome_install_dir}"
          exe_path = biome_install_dir
          exe_file = File.expand_path(File.join(biome_install_dir, 'biome'))
        else
          if Biome::Ruby::Upstream::NATIVE_PLATFORMS.keys.none? { |p| Gem::Platform.match_gem?(Gem::Platform.new(p), GEM_NAME) }
            raise UnsupportedPlatformException, <<~MESSAGE
              #{GEM_NAME} does not support the #{platform} platform
              See https://github.com/michebble/biome-ruby#using-a-local-installation-of-biome
              for more details.
            MESSAGE
          end

          exe_file = Dir.glob(File.expand_path(File.join(exe_path, '*', 'biome'))).find do |f|
            Gem::Platform.match_gem?(Gem::Platform.new(File.basename(File.dirname(f))), GEM_NAME)
          end
        end

        if exe_file.nil? || !File.exist?(exe_file)
          raise ExecutableNotFoundException, <<~MESSAGE
            Cannot find the biome executable for #{platform} in #{exe_path}

            If you're using bundler, please make sure you're on the latest bundler version:

                gem install bundler
                bundle update --bundler

            Then make sure your lock file includes this platform by running:

                bundle lock --add-platform #{platform}
                bundle install

            See `bundle lock --help` output for details.

            If you're still seeing this message after taking those steps, try running
            `bundle config` and ensure `force_ruby_platform` isn't set to `true`. See
            https://github.com/michebble/biome-ruby#check-bundle_force_ruby_platform
            for more details.
          MESSAGE
        end

        exe_file
      end
    end
  end
end
