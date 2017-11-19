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
