require "rack/jekyll"
run Rack::Jekyll.new(force_build: true, auto: true)
