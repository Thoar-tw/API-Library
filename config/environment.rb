# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'yaml'
require 'json'

module YouTubeTrendingMap
  # Configuration for the App
  class App < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test do
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./init.rb'
      end
    end

    configure :development, :test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
    end

    configure :production do
      # Use deployment platform's DATABASE_URL environment variable
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end
    end

    # File for Youtube API
    CATEGORIES = YAML.safe_load(File.read('config/category.yml'))

    # Files for Country mapping
    COUNTRIES = YAML.safe_load(File.read('config/country.yml'))
    # COUNTRY_BORDERS_JSON = File.read('config/country_borders.json')
    # COUNTRY_CODE_JSON = File.read('config/country_code.json')
  end
end
