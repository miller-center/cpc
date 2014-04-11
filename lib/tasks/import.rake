require 'importers/oai_importer'
require 'importers/xml_importer'

namespace :import do
  desc "loads OAI data into Solr"
  task oai: :environment do
    if ENV['FILE']
      files = [ENV['FILE']]
    else
      files = Dir["#{Rails.root}/data/oai/*.xml"]
    end

    importer = OaiImporter.new

    files.each do |file|
      puts "Importing from #{file}..."
      importer.import(file)
    end
  end

end
