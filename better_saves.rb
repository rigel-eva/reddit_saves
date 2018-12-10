require 'redd'
require 'nokogiri'
require './tumblr_handler.rb'
Tumblr.configure do |config|
	config.consumer_key = ENV['TUMBLR_KEY']
	config.consumer_secret = ENV['TUMBLR_SECRET']
	# config.oauth_token = ENV['TUMBLR_OAUTH']
	# config.oauth_token_secret = KEYS['TUMBLR_OAUTH_SECRET']
end
# def pixiv_extract(url) 
#   puts "\t\tPixiv"
# end
# def twitter_extract(url)  
#   puts "\t\tTwitter"
# end
# def tumblr_extract(url)
#   puts "\t\tTumblr"
# def patreon_extract(url) 
#   puts "\t\tPatreon"
# end
# def deviantart_extract(url) 
#   puts "\t\tDeviantArt"
# end
potential_urls={
  /pixiv.net/ => "Pixiv",# method(:pixiv_extract),
  /twitter.com/ => "Twitter",# method(:twitter_extract),
  /tumblr.com/ => "Tumblr",# method(:tumblr_extract),
  /patreon.com/ => "Patreon",# method(:patreon_extract),
  /deviantart.com/ => "Deviantart",# method(:deviantart_extract),
}
urlmatches=/(\S+(?:#{Regexp.union(potential_urls.keys)})\/\S+)/
session = Redd.it(user_agent: 'ReddBot', client_id: ENV['REDDIT_KEY'], secret: ENV['REDDIT_SECRET'], username:ENV['REDDIT_USER'], password:ENV['REDDIT_PASS'])
count=0
session.me.saved(limit: 100).each{|post| # unfortunatly the hard limit is 100 from the api (darn, guess I'll have to get creative then)
  puts "http://reddit.com"+post.permalink
  post.comments.each{|comment|
    # Saving ourselves a bit of headache with this line
    next unless (comment.class==Redd::Models::Comment)
    n_post=Nokogiri::HTML(comment.body_html)
    possible_links=n_post.xpath('.//a/@href').map{|links| links.to_s}.join(' ')
    matches=urlmatches.match(possible_links)
    unless(matches.nil?)
      puts "\tComment_Link: #{matches[0]}"
      # Ok we know it matches something ... let's find out what
      potential_urls.each{|k,v|
        match=k.match(possible_links)
        if (match.nil?)
          next
        end
        # and we now know we have an actual match, sweet
        puts v
      }
    end
  }
  count += 1
}
puts count
