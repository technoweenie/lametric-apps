require "sinatra"
require "json"
require "octokit"
require "uri"

ICONS = {
  :octocat => "i2184",
  :star => "i635",
  :watcher => "i2185",
}

get "/github/repository-stats/:o/:r" do
  cache_control :public, max_age: 540
  content_type :json

  repo = Octokit.repository("#{params[:o]}/#{params[:r]}")

  {
    :frames => [
      {
        :index => 0,
        :text => repo.name,
        :icon => ICONS[:octocat],
      },
      {
        :index => 1,
        :text => repo.stargazers_count.to_s,
        :icon => ICONS[:star],
      },
      {
        :index => 2,
        :text => repo.subscribers_count.to_s,
        :icon => ICONS[:watcher],
      },
    ]
  }.to_json
end

EVENTS = {
  "pull_request" => lambda { |json|
    pull = fetch_value(json, "pull_request", "title") || "???"
    repo = fetch_value(json, "repository", "name") || "???"
    sender = fetch_value(json, "sender", "login") || "???"

    lametric_post(
      [
        {
          :text => "#{repo}: #{pull} by #{sender}",
          :icon => :octocat,
        },
      ],
    )
  },

  "watch" => lambda { |json|
    repo = fetch_value(json, "repository", "name") || "???"
    sender = fetch_value(json, "sender", "login") || "???"

    lametric_post(
      [
        {
          :text => "#{repo}: #{sender}",
          :icon => :star,
        },
      ],
    )
  },
}

post "/github/events" do
  event_type = env["HTTP_X_GITHUB_EVENT"]
  if b = EVENTS[event_type]
    b.call(JSON.parse(request.body.read))
  else
    "Bad event type: #{event_type.inspect}"
  end
end

LAMETRIC_PUSH_URI = URI(ENV["LAMETRIC_PUSH_URL"].to_s)
LAMETRIC_HTTP_ARGS = [
  LAMETRIC_PUSH_URI.hostname, LAMETRIC_PUSH_URI.port,
  {:use_ssl => LAMETRIC_PUSH_URI.scheme == "https"}
]

def lametric_post(frames)
  frames.each_with_index do |f, i|
    f[:index] = i
    if icon = ICONS[f[:icon]]
      f[:icon] = icon
    end
  end

  uri = LAMETRIC_PUSH_URI
  res = Net::HTTP.start(*LAMETRIC_HTTP_ARGS) do |http|
    req = Net::HTTP::Post.new(uri)
    req.body = {:frames => frames}.to_json
    req.content_type = "application/json"
    req["Accept"] = "application/json"
    req["Cache-Control"] = "no-cache"
    req["X-Access-Token"] = ENV["LAMETRIC_PUSH_TOKEN"]
    http.request(req)
  end

  "Pushed to LaMetric: HTTP #{res.code}"
end

def fetch_value(hash, *keys)
  keys.inject(hash) do |memo, key|
    memo[key] || {}
  end
rescue TypeError
end
