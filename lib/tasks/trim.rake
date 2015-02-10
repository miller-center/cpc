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
      puts "Deleting selected records from #{Blacklight.solr.uri}"
      @trim_list.each do |id|
        Blacklight.solr.delete_by_query "id:#{id}"
      end
      Blacklight.solr.commit
    end
  end

end
