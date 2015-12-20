require "sinatra"
require "json"
require "octokit"

get "/github-repository-stats" do
  cache_control :public, max_age: 540
  content_type :json

  repos = %w(
    github/git-lfs
    lostisland/faraday
  )

  {
    :frames => [
      :index => 0,
      :text => "Stats\n" + status_for_repositories(repos),
      :icon => "i2184",
    ]
  }.to_json
end

def status_for_repositories(repositories)
  repositories.map do |nwo|
    repository = Octokit.repository(nwo)
    "#{repository.name} #{repository.stargazers_count}/#{repository.subscribers_count}"
  end.join("\n")
end
