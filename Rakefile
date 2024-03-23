require "io/console"
require "date"
require "yaml"

def multi_gets
  text = ""
  while (input = STDIN.gets) != "\n"
    text << input
  end

  text.chomp
end

DATA_FILE = "_data/concerts.yml"

config = nil
slug = nil

def slugify(str)
  str.downcase.split(/\s+/).join("-")
end

def read_concerts
  YAML.load(File.read(DATA_FILE))
end

def save_concert(slug, config)
  concerts = read_concerts
  concerts[slug] = config

  File.write(DATA_FILE, YAML.dump(concerts))
end

def read_concert_config(slug)
  raise "Cannot load concert without slug: #{slug.inspect}" unless slug

  read_concerts[slug]
end

CONCERTS_CONTENT = <<~HTML

{% include concerts-header.html %} {% include concert-details.html
concert=site.data.concerts.a-new-day %} {% include concerts-footer.html %}
HTML

default_concerts_front_matter = {
  "layout" => "default",
  "title" => "Upcoming Concerts",
  "description" => "Upcoming Foothills Philharmonic Concerts",
  "image" => "/images/upcoming-concerts.jpg",
  "permalink" => "/concerts/",
  "redirect_from" => ["/tickets"],
}

namespace :concerts do
  desc "Create a new concert"
  task :create do
    concerts = read_concerts
    # raise concerts.inspect

    config = {
      "year" => Date.today.year,
      "tickets" => [
        { "name" => "General admission", "price" => 20 },
        { "name" => "Students & Seniors", "price" => 10 },
        { "name" => "Children 12 and under", "price" => 0 },
      ],
    }

    %w[
      slug
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

    slug = config["slug"] = slugify(config["slug"])
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

    save_concert(slug, config)
  end
end
