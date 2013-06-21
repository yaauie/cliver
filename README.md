# Cliver

Sometimes Ruby apps shell out to command-line executables, but there is no
standard way to ensure those underlying dependencies are met. Users usually
find out via a nasty stack-trace and whatever wasn't captured on stderr.

`Cliver` is a simple gem that provides an easy way to make assertions about
command-line dependencies. Under the covers, it uses [rubygems/requirements][]
so it supports the version requirements you're used to providing in your
gemspec.

## Usage

```ruby
Cliver.assert('subl')                      # no version requirements
Cliver.assert('bzip2', '~> 1.0.6')         # one version requirement
Cliver.assert('racc', '>= 1.0', '< 1.4.9') # many version requirements
```

If the executable can't be found on your path at all, a 
`Cliver::Assertion::DependencyNotFound` exception is raised; if the version
reached does not meet the requirements, a `Cliver::Assertion::DependencyVersionMismatch`
exception is raised; both inherit from `Cliver::Assertion::DependencyNotMet`

## Advanced Usage:

Some programs don't provide nice 'version 1.2.3' strings in their `--version`
output; `Cliver` lets you provide your own version detector with a pattern.

```ruby
Cliver.assert('python', '~> 1.7',
              detector: Cliver::Detector.new(/(?<=Python )[0-9][.0-9a-z]+/))
```

Other programs don't provide a standard `--version`; `Cliver::Detector` also
allows you to provide your own arg to get the version:

```ruby
Cliver.assert('janky', '~> 10.1.alpha',
              detector: Cliver::Detector.new('--release-version'))
```

Alternatively, you can supply your own detector (anything that responds to
`#to_proc`) in the options hash or as a block, so long as it returns a
`Gem::Version`-parsable version number; if it returns nil or false when
version requirements are given, a descriptive `ArgumentError` is raised.

```ruby
Cliver.assert('oddball', '~> 10.1.alpha') do |oddball_path|
  File.read(File.expand_path('../VERSION', oddball_path)).chomp
end
```

And since some programs don't always spit out nice semver-friendly version
numbers at all, a filter proc can be supplied to clean it up. Note how the
filter is applied to both your requirements and the executable's output:

```ruby
Cliver.assert('built-thing', '~> 2013.4r8273',
              filter: proc { |ver| ver.tr('r','.') })
```

Since `Cliver` uses `Gem::Requirement` for version comparrisons, it obeys all
the same rules including pre-release semantics.

## Supported Platforms

The goal is to have full support for all platforms running ruby >= 1.9.2,
including rubinius and jruby implementations, as well as basic support for
legacy ruby 1.8.7. Windows has support in the codebase,
but is not available as a build target in [travis_ci][].

## See Also:

 - [YARD Documentation][yard-docs]
 - [Contributing](CONTRIBUTING.md)
 - [License](LICENSE.txt)


[rubygems/requirements]: https://github.com/rubygems/rubygems/blob/master/lib/rubygems/requirement.rb
[yard-docs]: http://yaauie.github.io/cliver/
[travis-ci]: https://travis-ci.org/yaauie/cliver
