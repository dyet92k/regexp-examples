# regexp-examples
[![Gem Version](https://badge.fury.io/rb/regexp-examples.svg)](http://badge.fury.io/rb/regexp-examples)
[![Build Status](https://travis-ci.org/tom-lord/regexp-examples.svg?branch=master)](https://travis-ci.org/tom-lord/regexp-examples/builds)
![Code Coverage](coverage/coverage-badge.png)

Extends the Regexp class with the method: Regexp#examples

This method generates a list of (some\*) strings that will match the given regular expression

\* If the regex has an infinite number of possible srings that match it, such as `/a*b+c{2,}/`,
or a huge number of possible matches, such as `/.\w/`, then only a subset of these will be listed.

## Usage

```ruby
/a*/.examples #=> [''. 'a', 'aa']
/b+/.examples #=> ['b', 'bb']
/this|is|awesome/.examples #=> ['this', 'is', 'awesome']
/foo-.{1,}-bar/.examples #=> ['foo-a-bar', 'foo-b-bar', 'foo-c-bar', 'foo-d-bar', 'foo-e-bar',
  # 'foo-aa-bar', 'foo-bb-bar', 'foo-cc-bar', 'foo-dd-bar', 'foo-ee-bar', 'foo-aaa-bar', 'foo-bbb-bar',
  # 'foo-ccc-bar', 'foo-ddd-bar', 'foo-eee-bar']
/https?:\/\/(www\.)?github\.com/.examples #=> ['http://github.com',
  # 'http://www.github.com', 'https://github.com', 'https://www.github.com']
/(I(N(C(E(P(T(I(O(N)))))))))*/.examples #=> ["", "INCEPTION", "INCEPTIONINCEPTION"]
/\x74\x68\x69\x73/.examples #=> ["this"]
/\u6829/.examples #=> ["栩"]
/what about (backreferences\?) \1/.examples #=> ['what about backreferences? backreferences?']
```

## Supported syntax

* All forms of repeaters (quantifiers), e.g. `/a*/`, `/a+/`, `/a?/`, `/a{1,4}/`, `/a{3,}/`, `/a{,2}/`
* Boolean "Or" groups, e.g. `/a|b|c/`
* Character sets (inluding ranges and negation!), e.g. `/[abc]/`, `/[A-Z0-9]/`, `/[^a-z]/`, `/[\w\s\b]/`
* Escaped characters, e.g. `/\n/`, `/\w/`, `/\D/` (and so on...)
* Non-capture groups, e.g. `/(?:foo)/`
* Capture groups, e.g. `/(group)/`
  * Including named groups, e.g. `/(?<name>group)/`
  * ...And backreferences(!!!), e.g. `/(this|that) \1/` `/(?<name>foo) \k<name>/`
  * Groups work fine, even if nested! e.g. `/(even(this(works?))) \1 \2 \3/`
* Control characters, e.g. `/\ca/`, `/\cZ/`, `/\C-9/`
* Escape sequences, e.g. `/\x42/`, `/\x3D/`, `/\x5word/`, `/#{"\x80".force_encoding("ASCII-8BIT")}/`
* Unicode characters, e.g. `/\u0123/`, `/\uabcd/`, `/\u{789}/`
* **Arbitrarily complex combinations of all the above!**

## Not-Yet-Supported syntax

* Options, e.g. `/pattern/i`, `/foo.*bar/m` - Using options will currently just be ignored, e.g. `/test/i.examples` will NOT include `"TEST"`

Using any of the following will raise a RegexpExamples::UnsupportedSyntax exception (until such time as they are implemented!):

* POSIX bracket expressions, e.g. `/[[:alnum:]]/`, `/[[:space:]]/`
* Named properties, e.g. `/\p{L}/` ("Letter"), `/\p{Arabic}/` ("Arabic character"), `/\p{^Ll}/` ("Not a lowercase letter")
* Subexpression calls, e.g. `/(?<name> ... \g<name>* )/` (Note: These could get _really_ ugly to implement, and may even be impossible, so I highly doubt it's worth the effort!)

## Impossible features ("illegal syntax")

The following features in the regex language can never be properly implemented into this gem because, put simply, they are not technically "regular"!
If you'd like to understand this in more detail, there are many good blog posts out on the internet. The [wikipedia entry](http://en.wikipedia.org/wiki/Regular_expression)'s not bad either.

Using any of the following will raise a RegexpExamples::IllegalSyntax exception:

* Lookarounds, e.g. `/foo(?=bar)/`, `/foo(?!bar)/`, `/(?<=foo)bar/`, `/(?<!foo)bar/`
* [Anchors](http://ruby-doc.org/core-2.2.0/Regexp.html#class-Regexp-label-Anchors) (`\b`, `\B`, `\G`, `^`, `\A`, `$`, `\z`, `\Z`), e.g. `/\bword\b/`, `/line1\n^line2/`
  * However, a special case has been made to allow `^` and `\A` at the start of a pattern; and to allow `$`, `\z` and `\Z` at the end of pattern. In such cases, the characters are effectively just ignored.

(Note: Backreferences are not really "regular" either, but I got these to work with a bit of hackery!)

## Known Bugs

Parsing character sets in regular expressions is extremely complicated. For example, just consider all the different edge cases that this gem _DOES_ work for:
```ruby
/[abc]/, /[A-Z0-9]/, /[^a-z]/, /[\w\s\b]/, [^\S], [-a-d], [\[\]], []\\\\\[]
```
(Yes, that last one really is valid syntax, and the gem generates examples correctly!)

However, there are a few obscure bugs that have yet to be resolved:

* Empty character groups, such as `/[^\w\W].examples` or `/[^\D0-9]/.examples` do not work properly. Not yet investigated the cause.
* Various (weird!) legal patterns do not get parsed correctly, such as `/[[wtf]]/.examples` - To solve this, I'll probably have to dig deep into the Ruby source code and imitate the actual Regex parser more closely.

Also:

* Not all examples are shown for repeated groups, e.g. `/[ab]{2}/.examples` does not contain `"ab"` or `"ba"`. This is due to a flaw in the current parser design, and will be fixed in the next major release.
* Mixing cature groups, or groups and backreferences does not work properly, e.g. `/(a|b)\1/.examples`. This is actually due to the same flaw as above, and will be fixed soon(-ish, probably).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'regexp-examples'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install regexp-examples

## Contributing

1. Fork it ( https://github.com/[my-github-username]/regexp-examples/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Don't forget to add tests!!
