require 'redd'
require 'nokogiri'
require './tumblr_handler.rb'
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
def getRedditSaves(session, top_level=true)
  saved_posts = session.me.saved(limit: 100)
  return nil if(saved_posts.to_ary.empty?)

  saved_posts.each do |post|
    puts "http://reddit.com"+post.permalink # A slight saftey just in case this blows up horribly
    post.unsave
  end
  saved_posts=saved_posts.to_ary.push(getRedditSaves(session, false)).flatten(1)
  if (top_level)
    return saved_posts.compact()
  else
    return saved_posts
  end
end
def resave_reddit_saves(posts)
  unless(posts.nil?)
    posts.each{|post| post.save()}
  end
end
def pixiv(loc); end
def twitter(loc); end
def patreon(loc); end
def deviantart(loc); end
def getURLSFromPosts(saves)
  potential_urls={
    /pixiv.net/ => method(:pixiv),
    /twitter.com/ => method(:twitter),
    /tumblr.com/ => method(:getTumblrPost_Filter),
    /patreon.com/ => method(:patreon),
    /deviantart.com/ => method(:deviantart),
  }
  urlmatches=/(\S+(?:#{Regexp.union(potential_urls.keys)})\/\S+)/
  saves.map{|save|
    if(save.class==Redd::Models::Comment)
      save = nil
      next
    end
    save.comments.to_ary.map!{|comment|
      unless(comment.class == Redd::Models::Comment)
        comment = nil
        next
      end
      n_post=Nokogiri::HTML(comment.body_html)
      possible_links=n_post.xpath('.//a/@href').map{|links| links.to_s}.join(' ')
      matches=urlmatches.match(possible_links)
      if(matches.nil?)
        comment=nil
        next
      else
        comment=matches[0]
      end
    }
  }.flatten.compact()
end
puts "Setting up Reddit Session"
reddit_session = Redd.it(user_agent: 'ReddBot', client_id: ENV['REDDIT_KEY'], secret: ENV['REDDIT_SECRET'], username:ENV['REDDIT_USER'], password:ENV['REDDIT_PASS'])
puts "Fetching Posts"
posts = getRedditSaves(reddit_session)
puts "Writing Posts to Screen"
unless(posts.nil?)
  posts.each{|post| puts "http://reddit.com"+post.permalink}
end 
puts "Resaving Posts"
resave_reddit_saves(posts)
puts "Writing URLS found in Posts"
getURLSFromPosts(posts).each{|url|
  puts "\t#{url}"
}