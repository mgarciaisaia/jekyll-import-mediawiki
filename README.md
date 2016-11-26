# jekyll-import-mediawiki

This is a work-in-progress MediaWiki to Jekyll migrator.

If things go well, time will come to convert this project into a [jekyll/jekyll-import](https://github.com/jekyll/jekyll-import) [Importer](https://import.jekyllrb.com/docs/contributing/#creating-a-new-importer).

Until then, it just scraps some MediaWiki you tell it to, and converts its pages to Jekyll-enabled markdown pages.

## Usage

Just `TARGET_SITE=http://your-site.sexy/ bundle exec ruby crawl.rb` and you should be good to go. Whenever the - pretty much verbose - script finishes, you should have a `_pages` directory with a subdirectory for each page.

You can simply copy those subdirectories to the root of your Jekyll site, and that'll work.

But if you love yourself just a little bit, you'll be better copying the whole `_pages` directory inside the Jekyll's one. For making Jekyll aware of those new files, you should add a `include: ['_pages']` entry in your `_config.yml`.

## Installation

Go to the project's root dir (the one with the `Gemfile`) and `bundle install`. **You should have `pandoc` available** on your system. Install it via your system's package manager (`sudo apt-get install pandoc`, `brew install pandoc`, etc).

## Bugs & contributions

Yes, please :)
