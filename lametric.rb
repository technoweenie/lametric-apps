require "sinatra"
require "json"
require "octokit"

get "/git-lfs" do
  cache_control :public, max_age: 240

  repository = Octokit.repository("github/git-lfs")
  {
    :frames => [
      :index => 0,
      :text => "Git LFS: #{repository.stargazers_count}/#{repository.watchers_count}",
      :icon => "i2184",
    ]
  }.to_json
end
