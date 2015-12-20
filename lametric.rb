require "sinatra"
require "json"
require "octokit"

get "/git-lfs" do
  cache_control :public, max_age: 480

  repository = Octokit.repository("github/git-lfs")
  {
    :frames => [
      :index => 0,
      :text => "Git LFS: #{repository.stargazers_count}/#{repository.subscribers_count}",
      :icon => "i2184",
    ]
  }.to_json
end

get "/github-repository-stats" do
  repos = params[:r].to_s.split(",").each(&:strip!)
  cache_control :public, max_age: 480

  {
    :frames => [
      :index => 0,
      :text => status_for_repositories(repos.first(5)),
      :icon => "i2184",
    ]
  }.to_json
end

def status_for_repositories(repositories)
  repositories.map do |nwo|
    repository = Octokit.repository(nwo)
    "#{repository.name} #{repository.stargazers_count}/#{repository.subscribers_count}"
  end.join(" | ")
end
