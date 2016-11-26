#!/usr/bin/env ruby
require 'spidr'
require 'pry-byebug'
require 'pandoc-ruby'
require 'cgi'

# raise "TARGET_SITE env variable is not defined - run `TARGET_SITE=http://example.com/ bundle exec ruby crawl.rb`" unless ENV['TARGET_SITE']

agent = Spidr::Agent.new
all_pages = agent.visit_page 'http://uqbar-wiki.org/index.php?title=Especial:Todas'
all_pages.links.each do |url|
  next unless url.start_with? '/index.php?title='
  page = agent.visit_page "http://uqbar-wiki.org#{url}&action=edit"

  begin
    puts page.url

    if page.url.to_s.include? 'action=edit' and !page.redirect?
      # You can't parse [X]HTML with regex ¯\_(ツ)_/¯
      # http://stackoverflow.com/a/1732454/641451
      matches = page.body.match(/<textarea([^>]*)>(.*)<\/textarea>/m)

      unless matches
        puts "Didn't find a textarea"
        next
      end

      mediawiki = matches[2]

      markdown = PandocRuby.convert(mediawiki, from: :mediawiki, to: :markdown_github)

      # make internal links work with fancy URLs
      #
      # generated pages are at /my-page/index.md, so links to 'other-page'
      # would go to /my-page/other-page instead of /other-page/ - that's
      # why we prefix with ../
      links_fixed = markdown.gsub(/]\(([^\)"]+) "wikilink"\)/, '](../\1)')

      title = page.title.match(/«(.*)»/)[1]
      location = CGI.parse(page.url.query)['title'].first
      frontmatter = <<-FRONTMATTER
---
layout: page
title: "#{title}"
permalink: "#{location}/"
---
FRONTMATTER

      directory_path = "_pages2/#{location}"
      FileUtils.mkdir_p directory_path
      File.open("#{directory_path}/index.md", 'w') do |f|
        f.puts frontmatter
        f.puts links_fixed

        puts "  Exported to #{f.path}"
      end
    end
  rescue => e
    binding.pry
    puts e
  end
end
