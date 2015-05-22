require 'importers/oai_importer'
require 'importers/xml_importer'

namespace :import do
  desc "imports single OAI file into Solr"
  task :single_oai, [:filename, :arg2] => :environment do |t,args|
    file =  args[:filename]
    options = {}
    options[:dry_run] = true if args[:arg1] =~ /dry/
    options[:xml] = true if args[:arg2] =~ /xml/
    options[:debug] = true if args[:arg2] =~ /debug/
    raise RuntimeError, "#{file} is not a file!" unless File.file?(file.to_s)
    importer = OaiImporter.new
    importer.import(file, options)
  end

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
    options[:debug] = true if args[:arg2] =~ /debug/

    importer = OaiImporter.new

    files.each do |file|
      puts "Importing from #{file}..."
      importer.import(file, options)
    end
  end

  desc "purges all records from Solr"
  task :purge, [:field,:value] => :environment do |t,args|
    field = args[:field] || "*"
    value = args[:value] || "*"
    query = "#{field}:\"#{value}\""
    if Blacklight.solr.uri
      puts "Deleting all records matching \"#{query}\" from #{Blacklight.solr.uri}"
      Blacklight.solr.delete_by_query query
      Blacklight.solr.commit
    end
  end

end
