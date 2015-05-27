require 'importers/xml_importer'

class OaiImporter < XmlImporter
  def initialize
    super

    @namespaces = {
      "xmlns" => "http://www.openarchives.org/OAI/2.0/static-repository",
      "dc" => "http://purl.org/dc/elements/1.1/",
      "dcterms" => "http://purl.org/dc/terms/",
      "oai" => "http://www.openarchives.org/OAI/2.0/",
      "oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/"
    }

    @record_delimiter = "//oai:record"

    @mappings_prefix = "./oai:metadata/oai_dc:dc/"
    @mappings = {
      "dc:id" => :id,
      "dc:publisher" => :publisher,
      "dcterms:isPartOf" => :isPartOf,
      # "dc:identifier" => :id,
      "dc:description" => :description,
      "dc:creator[1]" => :author_t,
      "dc:creator[position() != 1]" => :author_addl_t,
      "dc:date[1]" => :date, # :pub_date will get unformatted copy
      "dc:format" => :formats,
      "dcterms:medium" => :medium,
      "dc:title" => :title_t,
      "dc:contributor" => :contributor,
      "dc:provenance" => :provenance,
      "dc:subject" => :subject_t,
      "dc:source[not(@type='enhanced')]" => :source,
      "dc:source[@type='enhanced']" => :alt_source_t,
      "dc:type" => :type,
      "dc:language" => :language,
      "dc:relation" => :president_t,
      "dc:rights" => :rights
    }

    @filters = {
      :id => XmlImporter.gsub_filter(/\./, '_'),
    }
  end
end
