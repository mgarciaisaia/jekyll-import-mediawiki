#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'i18n'
require 'pandoc-ruby'
require 'cgi'
require 'git'

require 'pry-byebug'

raise "TARGET_SITE env variable is not defined - run `TARGET_SITE=http://example.com/ bundle exec ruby crawl.rb`" unless ENV['TARGET_SITE']

I18n.available_locales = [:en]
$authors = Set[]

class ::Git::Lib
  def commit(message, opts = {})
    arr_opts = []
    arr_opts << "--message=#{message}" if message
    arr_opts << '--amend' << '--no-edit' if opts[:amend]
    arr_opts << '--all' if opts[:add_all] || opts[:all]
    arr_opts << '--allow-empty' if opts[:allow_empty]
    arr_opts << "--author=#{opts[:author]}" if opts[:author]
    arr_opts << "--date=#{opts[:date]}" if opts[:date]

    command('commit', arr_opts)
  end
end

def slug(string)
  I18n.transliterate(string).downcase.strip.gsub(' ', '-').gsub('_', '-').gsub(/[^\w-]/, '-')
end

def all_pages(api)
  api.query = 'action=query&list=allpages&aplimit=max&format=json'
  response = JSON.parse Net::HTTP.get(api)
  puts response['query']['allpages'].map {|page| "#{page['pageid']} - #{page['title']}"}
  response['query']['allpages'].map {|page| page['pageid']}
end

# http://uqbar-wiki.org/api.php?action=query&format=json&prop=revisions&pageids=1405&rvlimit=max&rvprop=timestamp%7Cuser%7Ccomment%7Ccontent&rvdir=newer
def page_with_revisions(api, page_id)
  api.query = "action=query&format=json&prop=revisions&rvlimit=max&rvprop=timestamp%7Cuser%7Ccomment%7Ccontent&rvdir=newer&pageids=#{page_id}"
  response = JSON.parse Net::HTTP.get(api)
  response['query']['pages'][page_id.to_s]
end

def fix_links(markdown)
  markdown.gsub(/]\(([^\)"]+) "wikilink"\)/) { "](#{slug($1)}.md)" }
end

def comment(revision)
  revision['comment'].empty? ? "Revision without comments imported from MediaWiki" : revision['comment']
end

def author(revision)
  $authors << revision['user']
  "#{revision['user']} <#{revision['user']}@uqbar-project.org>"
end

def date(revision)
  revision['timestamp']
end

site_uri = URI(ENV['TARGET_SITE'])
site_uri.path += '/api.php'

directory_path = "_pages/"
repo = Git.init directory_path

pages = all_pages(site_uri)
pages.each do |page_id|
  page = page_with_revisions(site_uri, page_id)
  page_title = page['title']
  slug = slug(page_title)
  file = "#{slug}.md"

  page['revisions'].each do |revision|
    begin
      markdown = PandocRuby.convert(revision['*'], from: :mediawiki, to: :markdown_github)
    rescue => ex
      puts ex
      binding.pry
    end
    links_fixed = fix_links(markdown)
    comment = comment(revision)
    author = author(revision)
    date = date(revision)

    File.open("#{directory_path}#{file}", 'w') do |f|
      f.puts links_fixed

      puts "  Exported to #{f.path}"
    end

    repo.add file
    begin
      repo.commit(comment, author: author, date: date)
    rescue => ex
      puts ex
      binding.pry unless ex.message.end_with? 'nothing to commit, working tree clean'
    end
  end

  puts "Authors: #{$authors.to_a}"
end
