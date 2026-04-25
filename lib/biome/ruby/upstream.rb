# frozen_string_literal: true

module Biome
  module Ruby
    module Upstream
      VERSION = '2.4.11'

      # rubygems platform name => upstream release filename
      NATIVE_PLATFORMS = {
        'aarch64-linux-gnu' => 'biome-linux-arm64',
        'aarch64-linux-musl' => 'biome-linux-arm64-musl',
        'arm64-darwin' => 'biome-darwin-arm64',
        'x64-mingw-ucrt' => 'biome-win32-x64.exe',
        'x64-mingw32' => 'biome-win32-x64.exe',
        'x86_64-darwin' => 'biome-darwin-x64',
        'x86_64-linux-gnu' => 'biome-linux-x64',
        'x86_64-linux-musl' => 'biome-linux-x64-musl'
      }.freeze
    end
  end
end
