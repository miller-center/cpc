namespace :import do
  desc "trims selected (Lincoln) records from Solr"
  task :trim, [:filename]  => [:environment] do |t, args|
    @trim_list = []
    ID_FILE = args[:filename] || "#{Rails.root}/data/extra/bad_ids.txt"
    raise RuntimeError, "Unable to find id file #{ID_FILE}" unless File.exist? ID_FILE
    File.open(ID_FILE, 'r').each do |line| 
      @trim_list << line.match('^[^#]+$').to_s
    end

    if Blacklight.solr.uri
      puts "Deleting #{@trim_list.length} records from #{Blacklight.solr.uri}"
      puts Rails.env
      @trim_list.each_with_index do |id,index|
	if index % 1000 == 0 then puts "record id #{index}: #{id}" end 
        Blacklight.solr.delete_by_query 'id:"'+id+'"'
      end
      puts "Committing changes..."
      Blacklight.solr.commit
      puts "Done!"
    end
  end

end
