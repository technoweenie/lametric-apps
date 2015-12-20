require "sinatra"
require "json"

get "/git-lfs" do
  {
    :frames => [
      :index => 0,
      :text => "hi",
      :icon => "i2184",
    ]
  }.to_json
end
