require 'redd'
require 'nokogiri'
URLMATCHES=/(\S+(?:pixiv.net|twitter.com|tumblr.com|patreon.com|deviantart.com)\/\S+)/
session = Redd.it(user_agent: 'ReddBot', client_id: ENV['REDDIT_KEY'], secret: ENV['REDDIT_SECRET'], username:ENV['REDDIT_USER'], password:ENV['REDDIT_PASS'])
count=0
session.me.saved(limit: 100).each{|post| # unfortunatly the hard limit is 100 from the api (darn, guess I'll have to get creative then)
  puts "http://reddit.com"+post.permalink
  post.comments.each{|comment|
    # Saving ourselves a bit of headache with this line
    next unless (comment.class==Redd::Models::Comment)
    n_post=Nokogiri::HTML(comment.body_html)
    possible_links=n_post.xpath('.//a/@href').map{|links| links.to_s}.join(' ')
    matches=URLMATCHES.match(possible_links)
    unless(matches.nil?)
      puts "\t Comment_Link: #{matches[0]}"
    end
    # .each{|link|
    #   unless(URLMATCHES.match(link.to_s).nil?)
    #     puts "\tComment_Link: #{link.to_s}"
    #   end
    # }
  }
  count+=1
}
puts count

