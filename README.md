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
reached does not meet the requirements, a `Cliver::Assertion::VersionMismatch`
exception is raised.

## Advanced Usage:

Some programs don't provide nice 'version 1.2.3' strings in their `--version`
output; `Cliver` lets you provide your own matcher, whose first group is the
string version.

```ruby
Cliver.assert('python', '~> 1.7',
              detector: Cliver::Detector.new(/(?<=Python )[0-9][.0-9a-z]+/))
```

Other programs don't provide a standard `--version`; `Cliver` allows you to
provide your own arg:

```ruby
Cliver.assert('janky', '~> 10.1.alpha',
              detector: Cliver::Detector.new('--release-version'))
```

Alternatively, you can supply your own detector (anything that responds to
`#to_proc`) in the options hash or as a block, so long as it returns a
`Gem::Version`-parsable version number; if it returns nil or false when
version requirements are given, a descriptive ArgumentError is raised.

```ruby
Cliver.assert('oddball', '~> 10.1.alpha') do |oddball_path|
  File.read(File.expand_path('../VERSION', oddball_path)).chomp
end
```

Since `Cliver` uses `Gem::Requirement` for version comparrisons, it obeys all
the same rules including pre-release semantics.

## See Also:

 - [Contributing](CONTRIBUTING.md)
 - [License](LICENSE.txt)


[rubygems/requirements]: https://github.com/rubygems/rubygems/blob/master/lib/rubygems/requirement.rb
