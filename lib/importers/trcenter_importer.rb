require 'importers/oai_importer'

class TRCenterImporter < OaiImporter
  # customizations for Theodore Roosevelt Center partner
  def initialize
    super

    # remove inherited mappings
    @mappings.delete("dc:source[not(@type='enhanced')]")
    @mappings.delete("dc:source[not(@type='enhanced') and not(@type='additional')]")
    @mappings.delete("dc:source")
    @mappings.delete("dc:publisher")
    @mappings.delete("dc:relation")

    # add custom mappings
    @mappings["dc:publisher[@type='CPC partner' or @type='CPC Partner']"] = :publisher
    @mappings["dc:source[@type='url'][1]"] = :source
    @mappings["dc:source[@type='repository']"] = :collection_facet
    @mappings["dc:relation[@type='president']"] = :president_t
    @mappings["dc:relation"] = :related_name_t # limited exposure in Blacklight, but affects search
    @mappings["dc:coverage"] = :coverage_facet

  end

  def build_solr_add_doc(record, options={})
    solrdoc = {}
    solrdoc = super
    if options[:mutate]
      mutate(solrdoc, options[:mutate])
    end
    ap solrdoc if options[:dry_run]
    solrdoc
  end

  # a way to map field/content patterns to new fields and values
  def mutate(solrdoc, field)
    unless solrdoc[:coverage_facet].nil?
      case solrdoc[:coverage_facet]
      when /U\.S\. President/
        solrdoc[:president_t]="Roosevelt, Theodore, 1858-1919"
      when /Vice President/ && /1901/
        solrdoc[:president_t]="McKinley, William, 1843-1901"
      end
    end
    solrdoc
  end
end
