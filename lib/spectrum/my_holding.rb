#Will eventually be Holding, but need to deal with PlaceHold first. This goes with holdings method in JsonController
module Spectrum
  class MyHolding
    def initialize(holding={})
      @holding = holding
    end

    def caption
    end
    def headings
    end
    def name
    end
    def preExpanded
    end
    def rows
    end
    def type
      "pysical"
    end
  end
  class AlmaHolding < Spectrum::MyHolding
    def caption
      #Library Description?
    end
    def captionLink
      #link in giant yaml file in getholdings.pl
    end
    def notes
    end
    def headings 
      [
        "Action",
        "Description",
        "Status",
        "Call Number"
      ]
    end
    #type: physical
  end
  class HathiHolding < Spectrum::MyHolding
    def initialize(holding={}, alma_client=Spectrum::Utility::AlmaClient.new)
      @alma_client = alma_client
      super(holding)
      @holding.empty? ? @ph_exists = false : @ph_exists = get_ph_status
    end
    def caption
      "HathiTrust Digital Library"
    end
    def headings 
      [
        "Link",
        "Description",
        "Source",
      ]
    end
    def name
      "HathiTrust Sources"
    end
    def type
      "electronic"
    end
    def print_holding?
      @ph_exists
    end
    private
    #Need Item Picker. Can do this in here.
      #if @rightsCode =~ /^(pd|world|cc|und-world|ic-world)/ 
        #"Full text"
      #elsif @ph_exists
        #"Full text available (HathiTrust log in required)"
      #else
#        "Search only (no full text)"
    def get_ph_status
      oclcs = @holding["records"]&.values&.first&.dig("oclcs")
      oclcs.each do |oclc|
        response = @alma_client.get('/bibs',{query: {other_system_id: oclc, view: 'brief'}})
        if response.code == 200 && response.parsed_response["total_record_count"] > 0 
          return true 
        end
      end
      return false
    end
  end
  class HathiItem
    def initialize(item: item, ph_exists: ph_exists)
      @source = item['source'] || 'N/A'
      @url = item['itemURL']
      @description = item['enumcron'] || 'N/A'
      @rightsCode = item['rightsCode']
      @ph_exists = ph_exists
    end
    def to_a
      [
          {text: status, href: href},
          {text: @description},
          {text: @source}
      ]
    end
    def href
      @url
    end

    private
    def suffix
      if #condition
        "?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth"
      else
        ''
      end
    end
    def status
        "Search only (no full text)"
        #1: pd
        #2: ic
        #3: opb
        #4: orph
        #6: umall
        #7: world
        #5: und
        #8: nobody
        #9: pdus
        #10 - 15: Creative Commons (cc-by-nd, cc-by-nc-nd, etc) Treat same as world
      
    end
  end
  
  class PublicDomainHathiItem < HathiItem
    def status 
      "Full text"
    end
  end

  class EtasHathiItem < HathiItem
    def href
      "#{@url}?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth"
    end
    def status 
      "Full text available (HathiTrust log in required)"
    end
  end
end
