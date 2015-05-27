require 'importers/trcenter_importer'
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

  desc "imports UVA Press (Rotunda) collection data"
  task uvapress: :environment do
    # first purge all old records from this partner
    field = "publisher_facet"
    value = "University of Virginia Press"
    Rake::Task["import:purge"].invoke("#{field}", "#{value}")
    @files = [  "data/oai/ADMS-rotunda.oaidc.xml", "data/oai/BNFN-rotunda.oaidc.xml", "data/oai/JSMN-rotunda.oaidc.xml",
                "data/oai/ARHN-rotunda.oaidc.xml", "data/oai/GEWN-rotunda.oaidc.xml", "data/oai/TSJN-rotunda.oaidc.xml" ]
    @files.each do |fn|
      Rake::Task["import:single_oai"].execute(filename: "#{fn}")
    end
  end

  desc "imports Papers of Abraham Lincoln collection data"
  task lincolnpapers: :environment do
    # first purge all old records from this partner
    field = "publisher_facet"
    value = "The Papers of Abraham Lincoln"
    Rake::Task["import:purge"].invoke("#{field}", "#{value}")
    @files = [  "data/oai/lincoln-lc.xml", "data/oai/lincoln-rg-a.xml" , "data/oai/lincoln-rg-b.xml" ]
    @files.each do |fn|
      Rake::Task["import:single_oai"].execute(filename: "#{fn}")
    end
    # ensure removal of records without URLs
    Rake::Task["import:trim"].invoke
  end

  desc "imports Theodore Roosevelt Center collection data (uses custom importer)"
  task trcenter: :environment do
    # first purge all old records from this partner
    field = "publisher_facet"
    value = "Theodore Roosevelt Center"
    Rake::Task["import:purge"].invoke("#{field}", "#{value}")
    @files = [ "data/oai/trc_manuscript.xml", "data/oai/trc_motion.xml", "data/oai/trc_prints.xml" ]
    importer = TRCenterImporter.new
    @files.each do |fn|
      importer.import(fn)
    end
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
    query = "*:*" if query == "*:\"*\""
    if Blacklight.solr.uri
      puts "Deleting all records matching \"#{query}\" from #{Blacklight.solr.uri}"
      Blacklight.solr.delete_by_query query
      Blacklight.solr.commit
    end
  end

end
