require 'tumblr_client'
require 'fileutils'
require 'rest-client'
Tumblr.configure do |config|
  config.consumer_key = ENV['TUMBLR_KEY']
  config.consumer_secret = ENV['TUMBLR_SECRET']
end
FOLDER_LOCATION='./'
@tumblr_client = Tumblr::Client.new(client: :httpclient)
def getTumblrPost_Filter(loc)
  # ok just for te sake of sanity ... we are going to filter our original
  # getTumblrPost because otherwise it will pull down a random image.
  standard_post=/^(?:http||https):\/\/\S+.tumblr.com\/post\/\d+\/(?:[^\/]+)$/
  cutdown_post=/((?:http||https):\/\/\S+.tumblr.com\/post\/\d+\/\S+)\/\S+/
  loc=cutdown_post.match(loc)[1] if(standard_post.match(loc).nil?)
  getTumblrPost(loc)
end
def getTumblrPost(loc)
  @tumblr_client=Tumblr::Client.new(client: :httpclient)
  tDomain = getTumblrDomain loc
  tPost = getTumblrPostID loc
  i = 0
  download = []
  get = @tumblr_client.posts(tDomain, id: tPost.to_i)['posts'][0]['photos']
  get.each do |img|
    download[i] = img['original_size']['url']
    i += 1
  end
  fileLoc = ''
  fileLoc = if get.length > 1
              "#{FOLDER_LOCATION}/Tumblr/#{tPost}/"

            else
              "#{FOLDER_LOCATION}/Tumblr/"
            end
  FileUtils.mkdir_p fileLoc # covering our ass if the directory does not exist.
  download.each do |link|
    getFileFromURL(link, fileLoc)
  end
  true
  # rescue NoMethodError
  # puts "ERROR: It's likely that this particular link is not a link to a photo post: #{loc}"
end
def getTumblrDomain(loc)
  tURL = loc.split('/')
  tDomain = tURL[2]
end

def getTumblrPostID(loc)
  tURL = loc.split('/')
  tPost = tURL[-1]
  tPost = tURL[-2] unless /^[\d]+(\.[\d]+){0,1}$/ === tPost # We are checking to see if we got the actual tumblr post id.
  tPost
end
def getFileFromURL(webLoc,folderLoc)
  if(folderLoc[-1]!="/")
    folderLoc=folderLoc+"/"
  end
  open(folderLoc+webLoc.split("/")[-1], 'wb') do |file|
    file << RestClient::get(webLoc)
  end
end
