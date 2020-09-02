#Will eventually be Holding, but need to deal with PlaceHold first. This goes with holdings method in JsonController
module Spectrum
  attr_reader :preExpanded
  class MyHolding
    def initialize(holding: {}, preExpanded: false)
      @holding = holding
      @preExpanded = preExpanded
    end

    def caption
    end

    def headings
    end
    def name
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
    attr_reader :preExpanded
    def initialize(holding: {}, preExpanded: false, alma_client: Spectrum::Utility::AlmaClient.new)
      @alma_client = alma_client
      super(holding: holding, preExpanded: preExpanded)
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
    def rows
      @holding["items"].map do |item|
        pick_item(item)
      end
    end
    def to_h
      {
        caption: caption,
        headings: headings,
        name: name,
        preExpanded: @preExpanded,
        rows: rows.map{ |r| r.to_a },
        type: type
      }
    end
    private
    def pick_item(item)
      if item['rightsCode'] =~ /^(pd|world|cc|und-world|ic-world)/ 
        PublicDomainHathiItem.new(item)
      elsif print_holding? || item['orig'] == 'University of Michigan'
        EtasHathiItem.new(item)
      else
        HathiItem.new(item)
      end
    end

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
    def initialize(item)
      @source = item['orig'] || 'N/A'
      @url = item['itemURL']
      @description = item['enumcron'] || 'N/A'
    end
    def to_a
      [
          {text: status, href: href},
          {text: @description},
          {text: @source}
      ]
    end

    private
    def href
      @url
    end
    def status
        "Search only (no full text)"
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
      "Full text available, simultaneous access is limited (HathiTrust log in required)"
    end
  end
end
