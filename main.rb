require 'HTTParty'
require 'yaml'
require_relative 'api_key.rb'

class SteamApi
  include HTTParty
  debug_output $stdout
  base_uri 'https://api.steampowered.com/'

  default_options.update(verify: false)

  def QueryFiles(opts = {})
    puts "======================="
    puts require_relative 'api_key.rb'
    puts Config.api_key
    self.class.get("/service/PublishedFile/QueryFiles/v1/?key=#{Config.api_key}&input_json=#{URI::escape opts.to_json}")
  end

  def GetFileDetails(file)
    self.class.get("/IPublishedFileService/GetDetails/v1/?key=#{Config.api_key}&fileid=#{file}")
  end

  def GetPublishedFileDetails(file)
    self.class.post("/ISteamRemoteStorage/GetPublishedFileDetails/v1/?key=#{Config.api_key}",
      body: {
        itemcount: 1,
        publishedfileids: {
          0 => file
        }
      }
    )
  end
end

steam = SteamApi.new()

require 'sinatra'
require 'pry'

set :port, 80
set :environment, :development
set :server, "thin"
#set :bind, '0.0.0.0'
#set :dump_errors, false

get '/' do
  app = params[:app]
  visibility = params[:visibility]
  deleted = params[:deleted]
  autosave = params[:autosave]
  owner = params[:owner]
  searchtext = params[:search_text]

  @result = steam.QueryFiles(
    {
      querytype: 11,
      page: 1,
      numperpage: 100,
      creator_appid: 241100,
      appid: 241100,
      requiredtags: "",
      excludedtags: "",
      match_all_tags: "True",
      required_flags: "",
      omitted_flags: "",
      search_text: "",
      filetype: 15,
      child_publishedfileid: 0,
      days: 7,
      include_recent_votes_only: "False",
      cache_max_age_seconds: "3600",
      language: 0,
      required_kv_tags: [
        {
          key: "app",
          value: app
        },
        {
          key: "deleted",
          value: deleted
        },
        {
          key: "visibility",
          value: visibility
        }
      ],
      totalonly: "False",
      return_vote_data: "True",
      return_tags: "True",
      return_kv_tags: "False",
      return_previews: "False",
      return_children: "False",
      return_short_description: "True",
      return_for_sale_data: "False",
      return_metadata: "False"
    }
  ).body

  @result = JSON.parse(@result)

  erb :index, :locals => {app: app}
end

get "/query/:fileid" do
  @result = steam.GetFileDetails(params[:fileid]).body

  @result = JSON.parse(@result)
  
  erb :query
end

#resp = JSON.parse(response.body)

#resp["response"]["publishedfiledetails"].each do |k, v|
#  puts k["file_description"]
#  puts k["publishedfileid"]
#end