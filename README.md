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

You can use adsf programmatically in your Rack applications. [Nanoc](https://nanoc.ws/) uses adsf for its “view” command, for example. adsf consists of one middleware class that finds index filenames, and rewrites these requests so that Rack::File can be used to serve these files.

Here’s an example middleware/application stack that runs a web server with the "public/" directory as its web root:

	use Adsf::Rack::IndexFileFinder, :root => "public/"
	run Rack::File.new("public/")

The `:root` option is required; it should contain the path to the web root.

You can also specify an `:index_filenames` option, containing the names of the index filenames that will be served when a directory containing an index file is requested. Usually, this will simply be `[ 'index.html' ]`, but under different circumstances (when using IIS, for example), the array may have to be modified to include index filenames such as `default.html` or `index.xml`. Here’s an example middleware/application stack that uses custom index filenames:

	use Adsf::Rack::IndexFileFinder,
	  :root => "public/",
	  :index_filenames => %w( index.html index.xhtml index.xml )
	run Rack::File.new("public/")

Contributors
------------

* Ed Brannin
* Larissa Reis
* Mark Meves
