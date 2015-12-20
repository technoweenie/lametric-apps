require "sinatra"
require "json"
require "octokit"

get "/git-lfs" do
  repository = Octokit.repository("github/git-lfs")
  {
    :frames => [
      :index => 0,
      :text => "#{repository.stargazers_count}",
      :icon => "i2184",
    ]
  }.to_json
end
