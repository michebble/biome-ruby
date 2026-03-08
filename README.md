# Biome::Ruby

A self-contained `biome` executable. Javascript linting and formatting without a package manager.

*Inspired by [tailwindcss-ruby](https://github.com/flavorjones/tailwindcss-ruby).*

## Installation

This gem wraps [the standalone executable version](https://biomejs.dev/guides/getting-started/) of Biome, the linting and formatting tool for JavaScript. These executables are platform specific, so there are actually separate underlying gems per platform, but the correct gem will automatically be picked for your platform.

Supported platforms are:

- arm64-darwin (macos-arm64)
- x64-mingw32 (windows-x64)
- x64-mingw-ucr (windows-x64)
- x86_64-darwin (macos-x64)
- x86_64-linux (linux-x64)
- aarch64-linux (linux-arm64)
- arm-linux (linux-armv7)

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add biome-ruby
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install biome-ruby
```

### Using a local installation of `biome`

If you are not able to use the vendored standalone executables (for example, if you're on an unsupported platform), you can use a [local installation](https://biomejs.dev/guides/manual-installation/) of the `biome` executable by setting an environment variable named `BIOME_INSTALL_DIR` to the directory path containing the executable.

For example, if you've installed `biome` so that the executable is found at `/path/to/node_modules/bin/biome`, then you should set your environment variable like so:

``` sh
BIOME_INSTALL_DIR=/path/to/node_modules/bin
```

or, for relative paths like `./node_modules/.bin/biome`:

``` sh
BIOME_INSTALL_DIR=node_modules/.bin
```


## Versioning

This gem will always have the same version number as the underlying biome release. For example, the gem with version vx will package upstream biome vx.

If there ever needs to be multiple releases for the same version of biome, the version will contain an additional digit. For example, if we re-released biome vx, it might be shipped in gem version vx.1 or vx.2.

## Usage


### Command line

This gem provides an executable `biome` shim that will run the vendored standalone executable.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/michebble/biome-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Biome is [MIT licensed](https://github.com/biomejs/biome/blob/main/LICENSE-MIT) or [Apache 2.0 licensed](https://github.com/biomejs/biome/tree/main/LICENSE-APACHE)

