require "io/console"
require "date"
require "yaml"
require "active_support"
require "active_support/inflector"
require "active_support/core_ext"

def multi_gets
  text = ""
  while (input = STDIN.gets) != "\n"
    text << input
  end

  text.chomp
end

CONCERT_DATA_FILE = "_data/concerts.yml"
SEASON_DATA_FILE = "_data/seasons.yml"

config = nil
slug = nil

def read_concerts
  YAML.load(File.read(CONCERT_DATA_FILE), permitted_classes: [Date])
end

def save_concert(slug, config)
  concerts = read_concerts
  concerts[slug] = config

  File.write(CONCERT_DATA_FILE, YAML.dump(concerts))
end

def read_concert_config(slug)
  raise "Cannot load concert without slug: #{slug.inspect}" unless slug

  read_concerts[slug]
end

def concert_year(concert)
  Date.parse(concert["concert_dates"].first["date"]).year
end

namespace :concerts do
  desc "Create a new concert"
  task :create do
    concerts = read_concerts
    # raise concerts.inspect

    config = {
      "tickets" => [
        { "name" => "General admission", "price" => 20 },
        { "name" => "Students & Seniors", "price" => 15 },
        { "name" => "Children 12 and under", "price" => 0 },
      ],
    }

    %w[
      name
      subtitle
      description
      host
      event_url
    ].each do |field|
      STDOUT.print "Enter #{field}: "

      config[field] =
        if field == "description"
          multi_gets
        else
          STDIN.gets.chomp
        end
    end

    config["slug"] ||= config["name"].parameterize
    slug = config["slug"]
    if concerts.key?(slug)
      config = concerts[slug].merge(config)
    end

    puts "Concert dates!"

    Rake::Task["concerts:dates"].invoke
  end

  desc "Add a date to a concert"
  task :dates do
    slug ||= begin
      puts "Concert slug: "
      slugify(STDIN.gets.chomp)
    end

    config ||= read_concert_config(slug)

    config["concert_dates"] ||= []
    concert_dates = config["concert_dates"]

    loop do
      puts "Enter a concert date? (y/N)"
      break unless STDIN.getch&.downcase == "y"

      concert_date = {}

      %w[
        date
        time
        location_slug
        tickets_url
      ].each do |field|
        STDOUT.print "Enter #{field}: "

        concert_date[field] =
          if field == "description"
            multi_gets
          else
            STDIN.gets.chomp
          end
      end

      concert_dates << concert_date
    end

    config["year"] = concert_year(config)

    save_concert(slug, config)

    Rake::Task["concerts:generate"].invoke
  end

  desc "Auto-generate concert listings"
  task :generate do
    concerts = read_concerts.values.sort_by { |concert| concert["concert_dates"].min { |concert_date| Date.parse(concert_date["date"]) }["date"] }
    upcoming_concerts = concerts.filter do |concert|
      concert["concert_dates"].any? { |concert_date| Date.parse(concert_date["date"]) >= Date.today }
    end

    concerts_front_matter = {
      "layout" => "default",
      "title" => "Upcoming Concerts",
      "description" => "Upcoming Foothills Philharmonic Concerts",
      "image" => "/images/upcoming-concerts.jpg",
      "permalink" => "/concerts/",
      "redirect_from" => ["/tickets"],
    }

    # Next concert details
    next_concert = upcoming_concerts.first
    if next_concert
      concerts_front_matter["description"] = "Upcoming Concerts — #{next_concert["name"]}"
      concerts_front_matter["image"] = "/images/concerts/#{next_concert["year"] }/#{next_concert["slug"] }/banner.jpg"
    end

    # Generate concerts listing
    concerts_content = [
      YAML.dump(concerts_front_matter).chomp,
      "---",
      "{% include concerts-header.html %}",
    ]

    if upcoming_concerts.size > 0
      upcoming_concerts.each do |concert|
        concerts_content << "{% include concert-details.html concert=site.data.concerts.#{concert["slug"]} %}"
        concerts_content << "<hr />"
      end
    else
      concerts_content << "{% include concerts-empty.html %}"
    end

    concerts_content << "{% include concerts-footer.html %}"

    File.write("concerts/index.html", concerts_content.join("\n"))

    # Generate landing pages for all concerts
    concerts.each do |concert|
      front_matter = {
        "layout" => "default",
        "title" => concert["name"],
        "description" => concert["subtitle"],
        "image" => "/images/concerts/#{concert["year"] }/#{concert["slug"] }/banner.jpg",
      }

      content = [
        YAML.dump(front_matter).chomp,
        "---",
        "{% include concert-details.html concert=site.data.concerts.#{concert["slug"]} %}",
      ]

      FileUtils.mkdir_p("concerts/#{concert["year"]}")
      File.write("concerts/#{concert["year"]}/#{concert["slug"]}.html", content.join("\n"))
    end
  end
end

def read_seasons
  YAML.load(File.read(SEASON_DATA_FILE), permitted_classes: [Date])
end

def save_season(slug, config)
  seasons = read_seasons
  seasons[slug] = config

  File.write(SEASON_DATA_FILE, YAML.dump(seasons))
end

def read_season_config(slug)
  raise "Cannot load season without slug: #{slug.inspect}" unless slug

  read_seasons[slug]
end

def season_year(season)
  Date.parse(concert["concert_dates"].first["date"]).year
end

namespace :seasons do
  desc "Auto-generate season listings"
  task :generate do
    seasons = read_seasons.sort_by { |slug, season| season["first_rehearsal"] }
    upcoming_seasons = seasons.filter { |slug, season| season["first_rehearsal"] < 1.month.ago }

    # Generate landing pages for all seasons
    seasons.each do |slug, season|
      front_matter = {
        "layout" => "default",
        "title" => season["name"],
        "description" => season["subtitle"],
      }

      content = [
        YAML.dump(front_matter).chomp,
        "---",
        "{% include season-details.html season=site.data.seasons.#{slug} %}",
      ]

      FileUtils.mkdir_p("join/#{season["year"]}")
      File.write("join/#{season["year"]}/#{slug}.html", content.join("\n"))
    end
  end
end
