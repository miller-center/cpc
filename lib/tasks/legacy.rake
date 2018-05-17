namespace :legacy do
  require 'csv'
  require 'date'

  desc "Creates Collections objects from ExpressionEngine csv data file"
  task :create_collections, [:filename] => :environment do |t,args|
    # get the data file
    @files = []
    if args[:filename] && File.exist?(args[:filename].to_s)
      @files << args[:filename]
    else
      @files = Dir.glob("data/extra/collections/ee_collections_w_annotations.csv")
    end

    # parse the file
    @files.each do |fn|
      @data = []
      CSV.foreach(fn, col_sep: ";;;", quote_char: "'", headers: true, return_headers: false) do |row| 
        @data << row 
      end
    end

    # create Rails objects
    @data.each_with_index do |datum,i|
      # ensure you have a valid number for Collection id
      raise RuntimeError "no id for item #{i}!" unless datum["id"] && datum["id"].to_i > 1

      # create object with local (non-relational) data added
      obj = Collection.create( 
        id: datum["id"],
        name: datum["title"],
        description: datum["collection_description"],
        size: datum["size_classification"],
        precisesize: datum["size_precise"],
        allpres: datum["all_presidents?"],
      )
      obj.save!
    end

  end

  desc "Creates Presidents objects from ExpressionEngine csv data file"
  task :create_presidents, [:filename] => :environment do |t,args|
    # get the data file
    @files = []
    if args[:filename] && File.exist?(args[:filename].to_s)
      @files << args[:filename]
    else
      @files = Dir.glob("data/extra/collections/ee_presidents.csv")
    end

    # parse the file
    @files.each do |fn|
      @data = []
      CSV.foreach(fn, col_sep: ";;;", quote_char: "'", headers: true, return_headers: false) do |row| 
        @data << row 
      end
    end

    # create Rails objects
    @data.each_with_index do |datum,i|
      # ensure you have a valid number for President id
      raise RuntimeError "no id for item #{i}!" unless datum["id"] && datum["id"].to_i > 1
      puts "Creating President for legacy record id: #{datum["id"]}"
      # clean up Unix datetimes
      puts "Converting datum #{["birth_date"]} to datetime"
      bdate = DateTime.strptime(datum["birth_date"],'%s')
      ddate = DateTime.strptime(datum["death_date"],'%s')
      idate = DateTime.strptime(datum["inauguration_date"],'%s')
      edate = DateTime.strptime(datum["date_ended"],'%s')

      # create object with local (non-relational) data added
      obj = President.create( id: datum["id"],
        title: datum["title"],
        fullname: datum["full_name"],
        lastname: datum["last_name"],
        birthdate: bdate,
        deathdate: ddate,
        birthplace: datum["birthplace"],
        deathplace: datum["place_of_death"],
        education: datum["education"],
        religion: datum["religion"],
        career: datum["career"],
        party: datum["party"],
        nicknames: datum["nicknames"],
        marriage: datum["marriage"],
        children: datum["children"],
        inaugurationdate: idate,
        enddate: edate,
        number: datum["president_number"],
        writings: datum["writings"],
      )
      obj.save!
    end


  end

  desc "Creates Organizations objects from ExpressionEngine csv data file"
  task create_orgs: :environment do
  end

  desc "Links Collections to Presidents"
  task :link_colls_to_pres, [:filename] => :environment do |t,args|
  # get the data file
    @files = []
    if args[:filename] && File.exist?(args[:filename].to_s)
      @files << args[:filename]
    else
      @files = Dir.glob("data/extra/collections/ee_collections_w_annotations.csv")
    end

    # parse the file
    @files.each do |fn|
      @data = []
      CSV.foreach(fn, col_sep: ";;;", quote_char: "'", headers: true, return_headers: false) do |row| 
        @data << row 
      end
    end

    # update Rails objects
    @data.each_with_index do |datum,i|
      collection_id = datum[0]
      president_ids = datum[6]
      list = president_ids.split(',') # can have multiple values

      if Collection.exists?(collection_id)

        collection = Collection.find(collection_id)
        # link each president you have to this collection
        list.each do |item|
          item = item.to_i
          unless item.in?(collection.president_ids) || item == 0
            president = President.find(item)
            collection.presidents << president
          end
        end

        # save changes
        collection.save!

      end # end if
    end # end each_with_index


  end

  desc "Links Collections to Organizations"
  task link_colls_to_orgs: :environment do
  end

  desc "Creates Categories annotations for Collections from ExpressionEngine csv data file"
  task create_orgs: :environment do
  end

  desc "Creates Categories annotations for Organizations from ExpressionEngine csv data file"
  task create_orgs: :environment do
  end

end
