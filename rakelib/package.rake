# frozen_string_literal: true

#
#  Rake tasks to manage native gem packages with binary executables from biomejs/biome
#
#  TL;DR: run "rake package"
#
#  The native platform gems (defined by Biome::Ruby::Upstream::NATIVE_PLATFORMS) will each contain
#  two files in addition to what the vanilla ruby gem contains:
#
#     exe/
#     ├── biome                             #  generic ruby script to find and run the binary
#     └── <Gem::Platform architecture name>/
#         └── biome                         #  the biome binary executable
#
#  The ruby script `exe/biome` is installed into the user's path, and it simply locates the
#  binary and executes it. Note that this script is required because rubygems requires that
#  executables declared in a gemspec must be Ruby scripts.
#
#  As a concrete example, an x86_64-linux system will see these files on disk after installing
#  biome-ruby-1.x.x-x86_64-linux.gem:
#
#     exe/
#     ├── biome
#     └── x86_64-linux/
#         └── biome
#
#  So the full set of gem files created will be:
#
#  - pkg/biome-ruby-1.0.0.gem
#  - pkg/biome-ruby-1.0.0-aarch64-linux.gem
#  - pkg/biome-ruby-1.0.0-arm64-darwin.gem
#  - pkg/biome-ruby-1.0.0-x86_64-darwin.gem
#  - pkg/biome-ruby-1.0.0-x86_64-linux.gem
#
#  Note that in addition to the native gems, a vanilla "ruby" gem will also be created without
#  either the `exe/biome` script or a binary executable present.
#
#
#  New rake tasks created:
#
#  - rake gem:ruby           # Build the ruby gem
#  - rake gem:aarch64-linux  # Build the aarch64-linux gem
#  - rake gem:arm64-darwin   # Build the arm64-darwin gem
#  - rake gem:x86_64-darwin  # Build the x86_64-darwin gem
#  - rake gem:x86_64-linux   # Build the x86_64-linux gem
#  - rake download           # Download all biome binaries
#
#  Modified rake tasks:
#
#  - rake gem                # Build all the gem files
#  - rake package            # Build all the gem files (same as `gem`)
#  - rake repackage          # Force a rebuild of all the gem files
#
#  Note also that the binary executables will be lazily downloaded when needed, but you can
#  explicitly download them with the `rake download` command.
#
require 'rubygems/package_task'
require 'open-uri'
require_relative '../lib/biome/ruby/upstream'

def biome_download_url(filename)
  "https://github.com/biomejs/biome/releases/download/@biomejs/biome@#{Biome::Ruby::Upstream::VERSION}/#{filename}"
end

BIOME_RUBY_GEMSPEC = Bundler.load_gemspec('biome-ruby.gemspec')

# prepend the download task before the Gem::PackageTask tasks
task package: :download

gem_path = Gem::PackageTask.new(BIOME_RUBY_GEMSPEC).define
desc 'Build the ruby gem'
task 'gem:ruby' => [gem_path]

exepaths = []
Biome::Ruby::Upstream::NATIVE_PLATFORMS.each do |platform, filename|
  BIOME_RUBY_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir, platform) # "exe/x86_64-linux"
    exepath = File.join(exedir, 'biome') # "exe/x86_64-linux/biome"
    exepaths << exepath

    # modify a copy of the gemspec to include the native executable
    gemspec.platform = platform
    gemspec.files += [exepath, 'LICENSE-DEPENDENCIES']

    # create a package task
    gem_path = Gem::PackageTask.new(gemspec).define
    desc "Build the #{platform} gem"
    task "gem:#{platform}" => [gem_path]

    directory exedir
    file exepath => [exedir] do
      release_url = biome_download_url(filename)
      warn "Downloading #{exepath} from #{release_url} ..."

      # lazy, but fine for now.
      URI.parse(release_url).open do |remote|
        File.binwrite(exepath, remote.read)
      end
      FileUtils.chmod(0o755, exepath, verbose: true)
    end
  end
end

# need to figure this out
# desc 'Validate checksums for biome binaries'
# task 'check' => exepaths do
#   sha_filename = File.absolute_path("../package/biome-#{Biome::Ruby::Upstream::VERSION}-checksums.txt",
#                                     __dir__)
#   sha_url = if File.exist?(sha_filename)
#               sha_filename
#             else
#               biome_download_url('sha256sums.txt')
#             end
#   gemspec = BIOME_RUBY_GEMSPEC

#   checksums = URI.open(sha_url).each_line.to_h do |line|
#     checksum, file = line.split
#     [File.basename(file), checksum]
#   end

#   Biome::Ruby::Upstream::NATIVE_PLATFORMS.each do |platform, filename|
#     exedir = File.join(gemspec.bindir, platform) # "exe/x86_64-linux"
#     exepath = File.join(exedir, 'biome') # "exe/x86_64-linux/biome"

#     local_sha256 = Digest::SHA256.file(exepath).hexdigest
#     remote_sha256 = checksums.fetch(filename)

#     if local_sha256 == remote_sha256
#       puts "Checksum OK for #{exepath} (#{local_sha256})"
#     else
#       abort "Checksum mismatch for #{exepath} (#{local_sha256} != #{remote_sha256})"
#     end
#   end
# end

desc 'Download all biome binaries'
task 'download' => :check

CLOBBER.add(exepaths.map { |p| File.dirname(p) })
