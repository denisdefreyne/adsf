[![Gem version](https://img.shields.io/gem/v/adsf.svg)](http://rubygems.org/gems/adsf)
[![Gem downloads](https://img.shields.io/gem/dt/adsf.svg)](http://rubygems.org/gems/adsf)
[![Build status](https://img.shields.io/travis/ddfreyne/adsf.svg)](https://travis-ci.org/ddfreyne/adsf)
[![Code Climate](https://img.shields.io/codeclimate/github/ddfreyne/adsf.svg)](https://codeclimate.com/github/ddfreyne/adsf)
[![Code Coverage](https://img.shields.io/codecov/c/github/ddfreyne/adsf.svg)](https://codecov.io/gh/ddfreyne/adsf)

adsf
====

_adsf_ (**A** **D**ead **S**imple **F**ileserver) is a tiny static web server that you can launch instantly in any directory, like this:

	▸ ls -l
	total 0
	drwxr-xr-x  2 ddfreyne  staff  68 May 29 10:04 about
	drwxr-xr-x  2 ddfreyne  staff  68 May 29 10:04 contact
	-rw-r--r--  1 ddfreyne  staff   0 May 29 10:04 index.html
	drwxr-xr-x  2 ddfreyne  staff  68 May 29 10:04 projects

	▸ adsf
	[2017-11-19 11:49:20] INFO  WEBrick 1.3.1
	[2017-11-19 11:49:20] INFO  ruby 2.4.2 (2017-09-14) [x86_64-darwin17]
	[2017-11-19 11:49:20] INFO  WEBrick::HTTPServer#start: pid=95218 port=3000

… and now you can go to http://localhost:3000/ and start browsing.

See `adsf --help` for details.

To use `adsf --live-reload`, please install the separate `adsf-live` gem. (The live-reload support is not part of adsf itself, because the dependencies of `adsf-live` make it difficult to install under some circumstances.)

Using adsf programmatically
---------------------------

### IndexFileFinder

The `Adsf::Rack::IndexFileFinder` middleware makes Rack load an index file (e.g. `index.html`) when requesting a directory. For example, the following runs a web server with the 'public' directory as its web root:

```ruby
use Adsf::Rack::IndexFileFinder, root: 'public'
run Rack::File.new('public')
```

It takes the following options:

* `root` (required): the path to the web root

* `index_filenames` (optional; defaults to `['index.html']`): contains the names of the index filenames that will be served when a directory containing an index file is requested. Usually, this will simply be `['index.html']`, but under different circumstances (when using IIS, for example), the array may have to be modified to include index filenames such as `default.html` or `index.xml`. Here’s an example middleware/application stack that uses custom index filenames:

	```ruby
	use Adsf::Rack::IndexFileFinder,
		root: 'public',
		index_filenames: %w[index.html index.xhtml]
	run Rack::File.new('public')
	```

**Why not use `Rack::Static`?** Rack comes with `Rack::Static`, whose purpose is similar to, but not the same as, `Adsf::Rack::IndexFileFinder`. In particular:

* `Adsf::Rack::IndexFileFinder` does not serve files, unlike `Rack::Static`. `IndexFileFinder` only rewrites the incoming request and passes it on (usually to `Rack::File`).

* `Adsf::Rack::IndexFileFinder` supports multiple index files, while `Rack::Static` only supports one (you could have multiple `Rack::Static` middlewares, one for each index filenames, though).

* `Rack::Static` will report the wrong filename on 404 pages: when requesting a directory without an index file, it will e.g. report “File not found: /index.html” rather than “File not found: /”.

* When requesting a directory without specifying the trailing slash, `Adsf::Rack::IndexFileFinder` will redirect to the URL with a trailing slash, unlike `Rack::Static`. This mimics the behavior of typical HTTP servers. For example, when requesting `/foo`, when a `foo` directory exists and it contains `index.html`, `IndexFileFinder` will redirect to `/foo/`.

### Server

`Adsf::Server` runs a web server programmatically. For example:

```ruby
server = Adsf::Server.new(root: 'public')

%w[INT TERM].each do |s|
  Signal.trap(s) { server.stop }
end

server.run
```

It takes the following options:

* `root` (required): the path to the web root
* `index_filenames` (optional; defaults to `['index.html']`): (see above)
* `host` (optional; defaults to `'127.0.0.1'`): the address of the network interface to listen on
* `port` (optional; defaults to `3000`): the port ot listen on
* `handler` (optional): the Rack handler to use

Contributors
------------

* Ed Brannin
* Larissa Reis
* Mark Meves
* Vipul Amler
