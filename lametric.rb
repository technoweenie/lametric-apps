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

  frames = frames_for_repositories(repos)
  frames.each_with_index do |f, i|
    f[:index] = i
  end

  { :frames => frames }.to_json
end

def frames_for_repositories(repositories)
  repositories.inject([]) do |frames, nwo|
    repository = Octokit.repository(nwo)
    frames << {:text => repository.name, :icon => "i2184"}
    frames << {:text => repository.stargazers_count.to_s, :icon => "i635"}
    frames << {:text => repository.subscribers_count.to_s, :icon => "i2185"}
  end
end
