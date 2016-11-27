# jekyll-import-mediawiki

This _was_ a work-in-progress MediaWiki to Jekyll migrator. It still is a work-in-progress, but it doesn't mess with Jekyll anymore.

It exports every revision of each page of a MediaWiki to Github Flavored Markdown files in a new repo, so you can upload it to Github and navigate it there. It takes care of the internal links so they still work, and keeps track of the versions so you can see the whole history of the wiki.

Or at least _tries_ to ¯\\\_(ツ)\_/¯

## Usage

Just `TARGET_SITE=http://your-site.sexy/ bundle exec ruby crawl.rb` and you should be good to go. Whenever the - pretty much verbose - script finishes, you should have a `_pages` directory which is the full exported repository, ready to be pushed.

## Installation

Go to the project's root dir (the one with the `Gemfile`) and `bundle install`. **You should have `pandoc` available** on your system. Install it via your system's package manager (`sudo apt-get install pandoc`, `brew install pandoc`, etc).

You need a `git` client available in the command line, too - but chances are you already have one.

## Bugs & contributions

Yes, please :)
