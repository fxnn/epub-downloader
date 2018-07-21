# epub-downloader

Downloads an EPUB eBook, provided in unzipped form via HTTP, into a single `.epub` file.

Useful when eBooks are viewable via e.g. [epub.js](https://github.com/futurepress/epub.js/), but not provided in a zipped form.

## Dependencies

* bash
* sed
* wget
* `xpath` binary from Perl's [XML::XPath](https://metacpan.org/release/XML-XPath) module
* [zip](http://infozip.sourceforge.net/Zip.html)

## Usage

Calling

    epubdown.sh http://path.to/epub targetname
 
will download the eBook into the folder `targetname` (will be created) and finally pack it into `targetname.epub`.
