require "sinatra"
require "json"
require "octokit"

get "/git-lfs" do
  cache_control :public, max_age: 540

  repository = Octokit.repository("github/git-lfs")
  {
    :frames => [
      :index => 0,
      :text => "Git LFS: #{repository.stargazers_count}/#{repository.subscribers_count}",
      :icon => "i2184",
    ]
  }.to_json
end

get "/github-repository-stats/*" do
  repos = []
  params[:splat].each_with_index do |part, idx|
    if idx % 2 == 0 # even
      repos << part
    else
      repos.last << "/#{part}"
    end
  end
  repos.delete_if { |r| !r.include?("/") }

  cache_control :public, max_age: 540

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
