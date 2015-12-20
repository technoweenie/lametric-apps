require "sinatra"
require "json"
require "octokit"

get "/github-repository-stats/:o/:r" do
  cache_control :public, max_age: 540
  content_type :json

  repo = Octokit.repository("#{params[:o]}/#{params[:r]}")

  {
    :frames => [
      {
        :index => 0,
        :text => repo.name,
        :icon => "i2184",
      },
      {
        :index => 1,
        :text => repo.stargazers_count.to_s,
        :icon => "i635",
      },
      {
        :index => 2,
        :text => repo.subscribers_count.to_s,
        :icon => "i2185",
      },
    ]
  }.to_json
end
