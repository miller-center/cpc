# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController  
  include Blacklight::Marc::Catalog
  include Blacklight::Catalog
  include BlacklightAdvancedSearch::ParseBasicQ

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt => 'search',
      :rows => 10 
    }
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}' 
    #}
    config.default_document_solr_params = {
        :qt => 'document',
        :fl => '*',
        :rows => 1,
        :mlt => true,
        :"mlt.fl" => 'title_t,description,author_t',
        :"mlt.mindt" => 1,
        :"mlt.mintf" => 1,
        :"mlt.maxqt" => 3,
        :q => '{!raw f=id v=$id}' 
    }
    # More Like This params as they appear to Solr:
    # mlt=true&mlt.fl='title_t,description,author_t'&mlt.mindt=1&mlt.mintf=1&mlt.maxqt=3

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field 'format', :label => 'Format'
    config.add_facet_field 'subject_topic_facet', :label => 'Topic', :limit => 20 
    config.add_facet_field 'president_facet', :label => 'Presidency', :limit => 30
    config.add_facet_field 'language_facet', :label => 'Language', :limit => true 
    config.add_facet_field 'publisher_facet', :label => 'Partner', :limit => true
    config.add_facet_field 'collection_facet', :label => 'Collection', :limit => 15
    config.add_facet_field 'lc_1letter_facet', :label => 'Call Number' 
    config.add_facet_field 'subject_geo_facet', :label => 'Region' 
    config.add_facet_field 'subject_era_facet', :label => 'Era'  
    config.add_facet_field 'contributor_facet', :label => 'Related Person', show: false
    config.add_facet_field 'subject_facet', :label => 'Subject', show: false
    config.add_facet_field 'author_facet', :label => 'Creator', :limit => 25

    config.add_facet_field 'date_century_facet', :label => 'Century', :show => false, :sort => 'index', :collapse => true
    config.add_facet_field 'date_decade_facet', :label => 'Decade', :show => false, :sort => 'index', :collapse => true
    config.add_facet_field 'date_year_facet', :label => 'Year', :show => false, :sort => 'index', :collapse => true
    config.add_facet_field 'date_pivot_field', :label => 'Date', :pivot => ['date_century_facet', 'date_decade_facet', 'date_year_facet']

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    # config.add_index_field 'title_display', :label => 'Title'
    # config.add_index_field 'title_vern_display', :label => 'Title'
    config.add_index_field 'description', :label => 'Description'
    #config.add_index_field 'date', :label => 'Date'
    config.add_index_field 'pub_date', :label => 'Date'
    config.add_index_field 'published_display', :label => 'Partner', :link_to_search => 'publisher_facet'
    config.add_index_field 'author_display', :label => 'Author'
    config.add_index_field 'author_vern_display', :label => 'Author'
    config.add_index_field 'format', :label => 'Format'
    config.add_index_field 'language_facet', :label => 'Language'
    config.add_index_field 'publisher', :label => 'Published'
    config.add_index_field 'published_vern_display', :label => 'Published'
    config.add_index_field 'lc_callnum_display', :label => 'Call number'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'title_display', :label => 'Title'
    config.add_show_field 'title_vern_display', :label => 'Title'
    config.add_show_field 'subtitle_display', :label => 'Subtitle'
    config.add_show_field 'subtitle_vern_display', :label => 'Subtitle'
    config.add_show_field 'author_display', :label => 'Author'
    config.add_show_field 'author_vern_display', :label => 'Author'
    config.add_show_field 'pub_date', :label => 'Date'
    config.add_show_field 'description', :label => 'Description'
    config.add_show_field 'subject_t', :label => 'Subject', :link_to_search => 'subject_topic_facet'
    config.add_show_field 'format', :label => 'Format'
    config.add_show_field 'url_fulltext_display', :label => 'URL'
    config.add_show_field 'url_suppl_display', :label => 'More Information'
    config.add_show_field 'language_facet', :label => 'Language'
    config.add_show_field 'publisher', :label => 'Partner'
    config.add_show_field 'isPartOf', :label => 'Part of'
    config.add_show_field 'published_vern_display', :label => 'Published'
    config.add_show_field 'lc_callnum_display', :label => 'Call number'
    config.add_show_field do |field|
      field.field = 'contributor'
      field.label = 'Related persons'
      field.separator = "; "
      field.link_to_search = 'contributor_facet'
    end
    config.add_show_field 'isbn_t', :label => 'ISBN'
    config.add_show_field 'rights', :label => 'Rights'
    config.add_show_field 'source', :label => 'Source'
    config.add_show_field 'alt_source_t', :label => 'Enhanced Source'
    config.add_show_field 'alt_source_addnl_t', :label => 'Additional URL'
    config.add_show_field 'alt_source_portal_t', :label => 'Source'
    config.add_show_field 'author_addl_t', :label => 'Additional Authors'



    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise. 
    
    config.add_search_field 'all_fields', :label => 'All Fields'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end
    
    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = { 
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end
    
    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'search'
      field.solr_local_parameters = { 
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', :label => 'relevance'
    config.add_sort_field 'date_sort desc, title_sort asc', :label => 'year (newest first)'
    config.add_sort_field 'date_sort asc, title_sort asc', :label => 'year (oldest first)'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5

    # Advanced Search configuration
    config.advanced_search = {
      :form_solr_parameters => {
        'facet.field' => ['subject_topic_facet', 'president_facet', 'publisher_facet'],
        'facet.limit' => 25, # return all facet values
        'facet.sort' => 'count', # sort by byte order of values
      },
      :url_key => 'advanced',
      :qt => 'search'
    }
  end

end 
