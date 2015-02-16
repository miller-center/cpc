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
    @namespaces = HashWithIndifferentAccess.new
    @mappings_prefix = ''
    @mappings = HashWithIndifferentAccess.new
    @default_filter = self.class.strip_whitespace_filter
    @filters = HashWithIndifferentAccess.new

    yaml_path = File.expand_path('../../../config/solr.yml', __FILE__)
    @solr_config = YAML::load(ERB.new(IO.read(yaml_path)).result)[Rails.env.to_s]
    @solr = RSolr.connect :url => @solr_config["url"]
  end

  def import(file, options = {})
    dry_run = options[:dry_run] || false
    @debug = true if options[:debug]

    f = File.open(file)
    doc = Nokogiri::XML(f)
    f.close

    records = doc.xpath(record_delimiter, namespaces)
    puts "Importing #{records.length} records from #{file}"
    pbar = ProgressBar.new("importing", records.length) unless options[:dry_run]
    records.each do |record|
      if ! dry_run
        import_record_node(record, options)
      else
        response = display_record_node(record, options)
        case response
        when String
          STDERR.puts string
        else 
          STDOUT.puts response.inspect
        end
      end
      pbar.inc unless options[:dry_run]
    end

    unless dry_run
      begin
        @solr.commit
        @solr.optimize
      rescue StandardError => err
        STDERR.puts "Error importing from #{file}: #{err}"
      end
    end

    pbar.finish unless options[:dry_run]
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


  #private

  def build_solr_add_doc(record, options={})
    solrdoc = {}
    as_xml = true if options[:xml]

    @mappings.each do |xpath, docfield|
      record.xpath(mappings_prefix+xpath, namespaces).each do |node|
        field_val = node.text

        # try to make ISO8601-compatible dates
        docfield, field_val = parse_date_field(docfield, field_val)
        

        if solrdoc[docfield]
          if solrdoc[docfield].is_a?(Array)
            solrdoc[docfield] << field_val
          else
            solrdoc[docfield] = [solrdoc[docfield], field_val]
          end
        else
          solrdoc[docfield] = field_val
        end

        # copy unformatted date data to additional field
        if docfield == :date && node.text
          solrdoc[:pub_date] ||= []
          solrdoc[:pub_date] << node.text
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
    # add additional date facet fields, if date
    if solrdoc[:date]
      date = solrdoc[:date]
      if date[0..3] =~ /\d{4}/
        century = "#{date[0..1]}00s"
        decade = "#{date[0..2]}0s"
        year = "#{date[0..3]}"
        solrdoc[:date_century_t] = century
        solrdoc[:date_decade_t] = decade
        solrdoc[:date_year_t] = year
      end
    end
    # add presidential string, sortable by order of inauguration
    if solrdoc[:president_t]
      president = solrdoc[:president_t]
      p_code = ""
      case president
      when /Washington, George/
        p_code = "POTUS01 Washington, George, 1732-1799"
      when /Adams, John, 1735-1826/
        p_code = "POTUS02 Adams, John, 1735-1826"
      when /Jefferson, Th/
        p_code = "POTUS03 Jefferson, Thomas, 1743-1826"
      when /Madison, James, 1751-1836/
        p_code = "POTUS04 Madison, James, 1751-1836"
      when /Monroe, James/
        p_code = "POTUS05 Monroe, James, 1758 - 1831"
      when /Adams, John Q/
        p_code = "POTUS06 Adams, John Quincy, 1767-1848"
      when /Jackson, Andrew/
        p_code = "POTUS07 Jackson, Andrew, 1767-1845"
      when /Van Buren, Martin/
        p_code = "POTUS08 Van Buren, Martin, 1782-1862"
      when /Harrison, William/
        p_code = "POTUS09 Harrison, William Henry, 1773-1841"
      when /Tyler, John/
        p_code = "POTUS10 Tyler, John, 1790-1862"
      when /Polk, James/
        p_code = "POTUS11 Polk, James, 1795-1849"
      when /Taylor, Zachary/
        p_code = "POTUS12 Taylor, Zachary, 1784-1850"
      when /Fillmore, Millard/
        p_code = "POTUS13 Fillmore, Millard, 1800-1874"
      when /Pierce, Franklin/
        p_code = "POTUS14 Pierce, Franklin, 1804-1869" 
      when /Buchanan, James/
        p_code = "POTUS15 Buchanan, James, 1791-1868"
      when /Lincoln, Abraham/
        p_code = "POTUS16 Lincoln, Abraham, 1809-1865"
      when /Johnson, Andrew/
        p_code = "POTUS17 Johnson, Andrew, 1808-1875"
      when /Grant, Ulysses/
        p_code = "POTUS18 Grant, Ulysses S., 1822-1885"
      when /Hayes, Rutherford/
        p_code = "POTUS19 Hayes, Rutherford, B., 1822-1893"
      when /Garfield, James/
        p_code = "POTUS20 Garfield, James A., 1831-1881"
      when /Arthur, Chester/
        p_code = "POTUS21 Arthur, Chester A., 1829-1886"
      when /Cleveland, Grover/
        p_code = "POTUS22 Cleveland, Grover, 1837-1908"
      when /Harrison, Benjamin/
        p_code = "POTUS23 Harrison, Benjamin, 1833-1901"
      when /McKinley, William/
        p_code = "POTUS25 McKinley, William, 1843-1901"
      when /Roosevelt, T/
        p_code = "POTUS26 Roosevelt, Theodore, 1858-1919"
      when /Taft, William/
        p_code = "POTUS27 Taft, William Howard, 1857-1930"
      when /Wilson, Woodrow/
        p_code = "POTUS28 Wilson, Woodrow, 1856-1924"
      when /Harding, Warren/
        p_code = "POTUS29 Harding, Warren G., 1856-1923"
      when /Coolidge, Calvin/
        p_code = "POTUS30 Coolidge, Calvin, 1872-1933"
      when /Hoover, Herbert/
        p_code = "POTUS31 Hoover, Herbert, 1874-1964"
      when /Roosevelt, F/
        p_code = "POTUS32 Roosevelt, Franklin Delano, 1882-1945"
      when /Truman, Harry/
        p_code = "POTUS33 Truman, Harry S., 1884-1972"
      when /Eisenhower, D/
        p_code = "POTUS34 Eisenhower, Dwight D., 1890-1969"
      when /Kennedy, John/
        p_code = "POTUS35 Kennedy, John F. (Fitzgerald), 1917-1963"
      when /Johnson, Lyndon/
        p_code = "POTUS36 Johnson, Lyndon B., 1908-1973"
      when /Nixon/
        p_code = "POTUS37 Nixon, Richard Milhous, 1913-1994"
      when /Ford, G/
        p_code = "POTUS38 Ford, Gerald R., 1913-2006"
      when /Carter/
        p_code = "POTUS39 Carter, Jimmy, 1924-"
      when /Reagan/
        p_code = "POTUS40 Reagan, Ronald, 1911-2004"
      when /Bush, George H/
        p_code = "POTUS41 Bush, George H. W., 1924-"
      when /Clinton/
        p_code = "POTUS42 Clinton, William (Bill) J., 1946-"
      when /Bush, George W/
        p_code = "POTUS43 Bush, George W., 1946-"
      when /Obama, B/
        p_code = "POTUS44 Obama, Barack, 1961-"
      end
      solrdoc[:president_sorted_t]= p_code
    end
    solrdoc   
  end

  def display_record_node(record, options={})
    solrdoc = build_solr_add_doc(record, options)  
    raise RuntimeError unless solrdoc.kind_of? Hash

    if solrdoc.empty?
      "Skipping empty record"
    else
      solrdoc
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

  # extracted from build_solr_add_doc
  def parse_date_field(docfield, field_val)
    if docfield == :date && field_val =~ /\d{4}-\d{4}/ # e.g. 1756-1804
      begin
        puts "Case 0 #{field_val}" if @debug
        regex = Regexp.new(/\d{4}/) 
        result = regex.match(field_val)
        field_val = result[0] # index first date only
        if field_val =~ /^\d{4}$/
          field_val = Date.new(field_val.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      rescue
        field_val = node.text
      end
    elsif docfield == :date && field_val =~ /century/
      begin
        puts "Case 1 #{field_val}" if @debug
        regex = Regexp.new(/\d{2}/)
        result = regex.match(field_val)
        field_val = result[0].to_i.-(1).to_s + "50" # 18 becomes 1750, midpoint of 18th C.
        field_val = Date.new(field_val.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
      rescue
        field_val = node.text
      end
    elsif docfield == :date && field_val =~ /\d{4}-\d{2}/ && field_val !~ /\d{4}-\d{2}-\d{2}/  # e.g. 1862-09-XX, 1862-09
      begin
        puts "Case 1a #{field_val}" if @debug
        regex = Regexp.new(/(\d{4})-(\d{2})/)
        result = regex.match(field_val)
        date = Date.new(result[1].to_i)
        field_val = DateTime.new(date.year, result[2].to_i, 15, 0, 0, 0, 0).strftime('%Y-%m-%dT%H:%M:%SZ')
      rescue
        field_val = Date.new(field_val.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    elsif docfield == :date && field_val =~ /^\d{2,3}[X\?-]{1,2}/   # e.g. 18XX-XX-XX, 18??
      begin
        puts "Case 1b #{field_val}" if @debug
        regex = Regexp.new(/(\d{2,3})([X\?-]{1,2})/)
        result = regex.match(field_val)
        estimated_year = result[1]
        estimated_year.length > 2 ? estimated_year<<"5" : estimated_year<<"50"        
        date = Date.new(estimated_year.to_i)
        # set to Jan 1, estimated year = mid-point of available date resolution, e.g., 1850
        field_val = DateTime.new(date.year, 1, 1, 0, 0, 0, 0).strftime('%Y-%m-%dT%H:%M:%SZ')
      rescue
        field_val = Date.new(field_val.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    elsif docfield == :date && field_val.to_i > 0
      begin
        puts "Case 2 #{field_val}" if @debug
        if field_val.to_datetime # will raise exception unless true
          field_val = field_val.to_datetime.strftime('%Y-%m-%dT%H:%M:%SZ')
        end
      rescue
        field_val = Date.new(field_val.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
      end
    elsif docfield == :date && field_val =~ /(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)/i && field_val.to_datetime.year > 0
      begin
        puts "Case 3 #{field_val}" if @debug
        if field_val.to_datetime.year > 1492 # avoid insane values
          field_val = field_val.to_datetime.strftime('%Y-%m-%dT%H:%M:%SZ')
        else
          docfield  = :pub_date
          field_val
        end
      rescue
        field_val 
      end
    elsif docfield == :date && field_val =~ /circa/i
      begin
        puts "Case 4 #{field_val}" if @debug
        field_val = Date.new(field_val.gsub(/circa/i, '').strip.to_i).strftime('%Y-%m-%dT%H:%M:%SZ')
      rescue
        field_val 
      end
    else
      if docfield == :date
        puts "Case 5 #{field_val} new docfield = :pub_date" if @debug
        docfield = :pub_date # Solr typed as string, will handle strings that fail ISO 8601 validation 
      end
    end
    return docfield, field_val
  end

end
