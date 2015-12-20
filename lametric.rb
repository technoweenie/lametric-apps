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

  lines = lines_for_repositories(repos)
  frames = []
  lines.each_with_index do |l, i|
    frames << {
      :index => i,
      :text => l,
      :icon => "i2184",
    }
  end

  { :frames => frames }.to_json
end

def lines_for_repositories(repositories)
  repositories.inject([]) do |frames, nwo|
    repository = Octokit.repository(nwo)
    frames << repository.name
    frames << "#{repository.stargazers_count}/#{repository.subscribers_count}"
  end
end
