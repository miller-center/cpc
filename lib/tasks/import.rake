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

  desc "purges all records from Solr"
  task purge: :environment do
    if Blacklight.solr.uri
      puts "Deleting all records from #{Blacklight.solr.uri}"
      Blacklight.solr.delete_by_query '*:*'
      Blacklight.solr.commit
    end
  end

end
