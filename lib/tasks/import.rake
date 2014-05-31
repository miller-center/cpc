require 'importers/oai_importer'
require 'importers/xml_importer'

namespace :import do
  desc "loads OAI data into Solr; import:oai[dry_run] will dump data to stdout"
  task :oai, [:arg1, :arg2] => :environment do |t,args|
    if ENV['FILE']
      files = [ENV['FILE']]
    else
      files = Dir["#{Rails.root}/data/oai/*.xml"]
    end

    options = {}
    options[:dry_run] = true if args[:arg1] =~ /dry/
    options[:xml] = true if args[:arg2] =~ /xml/

    importer = OaiImporter.new

    files.each do |file|
      puts "Importing from #{file}..."
      importer.import(file, options)
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
