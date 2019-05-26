# Release notes for adsf

## 1.4.2 (2019-05-26)

Enhancements:

* Set `Cache-Control` HTTP header to prevent caching (#17, #18) [Daniel Aleksandersen]

## 1.4.1 (2018-02-02)

Fixes:

* [adsf-live] Fixed Windows compatibility (#14)

## 1.4.0 (2017-11-26)

Features:

* Added `--live-reload` option (requires `adsf-live`)

## 1.3.1 (2017-11-25)

Enhancements:

* Added headers for CORS (#9, #12)

## 1.3.0 (2017-11-19)

Features:

* Added `Adsf::Server`

## 1.2.1 (2016-03-14)

* Fixed compatibility with Ruby 2.3.0 (#3) [Vipul Amler]

## 1.2.0 (2013-11-29)

* Added `--local-only` and `--listen-address` options (#1) [Ed Brannin]

## 1.1.1

* Made SIGINT/SIGTERM cause proper exit

## 1.1.0

* Added support for custom index filenames [Mark Meves]

## 1.0.1

* Added runtime dependency on Rack

## 1.0.0

* Initial release
