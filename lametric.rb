require "sinatra"
require "json"
require "octokit"

get "/github-repository-stats/*" do
  repos = []
  params[:splat].first.split("/").each_with_index do |part, idx|
    if idx % 2 == 0 # even
      repos << part
    else
      repos.last << "/#{part}"
    end
  end
  repos.delete_if { |r| !r.include?("/") }

  cache_control :public, max_age: 540
  content_type :json

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
