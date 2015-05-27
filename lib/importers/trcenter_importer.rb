require 'importers/oai_importer'

class TRCenterImporter < OaiImporter
  # customizations for Theodore Roosevelt Center partner
  def initialize
    super

    # remove inherited mappings
    @mappings.delete("dc:source[not(@type='enhanced')]")
    @mappings.delete("dc:publisher")
    @mappings.delete("dc:relation")

    # add custom mappings
    @mappings["dc:publisher[@type='CPC partner' or @type='CPC Partner']"] = :publisher
    @mappings["dc:source[@type='url'][1]"] = :source
    @mappings["dc:relation[@type='president']"] = :president_t
    @mappings["dc:relation"] = :related_name_t # limited exposure in Blacklight, but affects search

  end
end
