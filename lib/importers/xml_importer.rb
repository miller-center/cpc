require 'nokogiri'
require 'rsolr'

##
# A base class for importing xml documents.
#
# ## Attributes: 
# +record_delimiter+ - an xpath expression that points to the records in a file
# +namespaces+ - a hash of all the namespace prefix => urls in the xml doc
# +mappings_prefix+ - (optional) if each mapping in +mappings+ shares the same
#                     prefix, using this can help DRY up the code
# +mappings+ - maps xpath expressions (searching from the +record_delimiter+
#              to solr document fields)
# +default_filter+ - sometimes we want to filter the value coming back from
#                    the xml document. 
#                    Filters are passed either a string or 
#                    an array of values (for each of the 
#                    nodes matching each xpath in mappings), and can return
#                    either an array (for multi-valued fields), a string, or
#                    `nil` to indicate that the field should not be added.
#
#                    The default filter strips whitespace from each array entry,
#                    and returns nil if there is no actual text.
# +filters+ - (optional) map from solr field names to filter functions.
#             See description of +default_filter+
##
class XmlImporter
  attr_accessor :record_delimiter,
                :namespaces,
                :mappings_prefix,
                :mappings,
                :default_filter,
                :filters

  def initialize
    @record_delimiter = ''
    @namespaces = {}
    @mappings_prefix = ''
    @mappings = {}
    @default_filter = self.class.strip_whitespace_filter
    @filters = {}

    yaml_path = File.expand_path('../../../config/solr.yml', __FILE__)
    @solr_config = YAML::load(ERB.new(IO.read(yaml_path)).result)[Rails.env.to_s]
    @solr = RSolr.connect :url => @solr_config["url"]
  end

  def import(file, options = {})
    dry_run = options[:dry_run] || false

    f = File.open(file)
    doc = Nokogiri::XML(f)
    f.close

    records = doc.xpath(record_delimiter, namespaces)
    puts "Importing #{records.length} records from #{file}"
    pbar = ProgressBar.new("importing", records.length)
    records.each do |record|
      if ! dry_run
        import_record_node(record, options)
      else
        display_record_node(record, options)
      end
      pbar.inc
    end

    unless dry_run
      begin
        @solr.commit
        @solr.optimize
      rescue StandardError => err
        STDERR.puts "Error importing from #{file}: #{err}"
      end
    end

    pbar.finish
  end

  # a default filter that strips whitespace from all values
  # (leaving them in an array if there are multiple)
  def self.strip_whitespace_filter
    @strip_whitespace_filter ||=
      ->(val) {
        if val.is_a?(Array)
          filtered_val = val.map{|v| v.strip}.select{|v| !v.empty?}
          filtered_val.length > 0 ? filtered_val : nil
        else
          filtered_val = val.to_s.strip
          filtered_val.empty? ? nil : filtered_val
        end
      }
  end

  # a filter that can be reused that will join multiple values
  # into a single string. If a string is passed to the filter, it
  # will simply be ignored.
  #
  # By default, this will join the strings together using a space, but 
  # you can specify an alternate string to use
  def self.join_filter(join_str = ' ')
    if @join_filter && join_str == ' '
      @join_filter
    else
      @join_filter = ->(val) {
        val.join(join_str) if val.is_a?(Array)
      }
    end
  end

  def self.gsub_filter(regex, replace)
    ->(val) {
      if val.is_a?(Array)
        val.map{|v| v.gsub(regex, replace)}
      else
        val.to_s.gsub(regex, replace)
      end
    }
  end


  private

  def build_solr_add_doc(record, options={})
    solrdoc = {}
    as_xml = true if options[:xml]

    @mappings.each do |xpath, docfield|
      record.xpath(mappings_prefix+xpath, namespaces).each do |node|
        field_val = node.text

        if solrdoc[docfield]
          if solrdoc[docfield].is_a?(Array)
            solrdoc[docfield] << field_val
          else
            solrdoc[docfield] = [solrdoc[docfield], field_val]
          end
        else
          solrdoc[docfield] = field_val
        end
      end

      filter = filters[docfield] || default_filter
      field_val = filter.call(solrdoc[docfield])
      if field_val.nil?
        solrdoc.delete(docfield)
      else
        solrdoc[docfield] = field_val
      end
    end 
    solrdoc   
  end

  def display_record_node(record, options={})
    solrdoc = build_solr_add_doc(record, options)  
    raise RuntimeError unless solrdoc.kind_of? Hash

    if solrdoc.empty?
      STDERR.puts "Skipping empty record"
    else
      STDOUT.puts solrdoc
    end    
  end

  def import_record_node(record, options={})
    solrdoc = build_solr_add_doc(record, options)  
    raise RuntimeError unless solrdoc.kind_of? Hash

    if solrdoc.empty?
      STDERR.puts "Skipping empty record"
      return
    end

    begin
      @solr.add(solrdoc)
    rescue StandardError => err
      STDERR.puts "Error importing record: #{err}\n\tDoc: #{solrdoc}"
    end
  end

end