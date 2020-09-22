require_relative '../spec_helper'
require 'spectrum/my_holding'
require 'spectrum/floor_location'
require 'spectrum/utility/alma_client'
require 'spectrum/item'
require 'spectrum/item_action'
require 'spectrum/item_description'
require 'spectrum/bib_record'
require 'spectrum/utility/hathi_client'
require 'marc'

describe Spectrum::AlmaHolding do
  context "default holding" do
    before(:each) do
      @bib_dbl = instance_double(Spectrum::BibRecord)
    end
    it "returns appropriate heading" do
      holding = described_class.new(bib: @bib_dbl)
      expect(holding.headings).to eq(["Action","Description","Status","Call Number"])
    end
  end
  context "one item holding" do
    before(:each) do

      @holding_record = double('Marc::Record')
      allow(@holding_record).to receive(:find_all)
      @init = {
        holding: JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_alma_holding.json')),
        items: JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_alma_item.json'))["item"],
        bib: @bib_dbl,
        collections_data: [],
        holding_record: @holding_record
      }
    end
    subject do
      described_class.new(**@init)
    end
    it "returns appropriate caption" do
      expect(subject.caption).to eq("Music")
    end
    it "returns appropriate name" do
      expect(subject.name).to eq("holdings")
    end
    it "returns appropriate captionLink" do
      @init[:collections_data] = [{"code" => 'MUSIC', "lib_info_link" => 'link'}] 
      expect(subject.captionLink).to eq({href: "link", text: "About location"})
    end
    context "notes" do
      it "returns empty array for no floor" do
        expect(subject.notes(nil)).to eq([])
      end
      it "returns floor item when floor is found" do
        expect(subject.notes('5th Floor')).to eq(['5th Floor'])
      end
    end
    context "rows" do
      it "returns an array of hashes" do
        item_dbl = instance_double('Spectrum::AlmaItem', to_a: {item: 'item'})
        factory_dbl = lambda{|item,bib| item_dbl}
        expect(subject.rows(factory_dbl)).to eq([{item: 'item'}])
      end
    end
    context "to_h" do
      before(:each) do
        @expected_output = JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_output.json'),symbolize_names: true)[1]
        @expected_output[:rows] = [[]] #assume AlmaItem to_a works

        allow(Spectrum::FloorLocation).to receive(:resolve)
        @item_dbl = instance_double('Spectrum::AlmaItem', to_a: [])
        @factory_dbl = lambda{|item,bib| @item_dbl}
        @floor_location = "5th Floor"
        @init[:collections_data] = [{"code" => 'MUSIC', "lib_info_link" => 'http://www.lib.umich.edu/location/music-library/unit/39'}] 
      end
      it "returns expected hash" do
        expect(subject.to_h(@factory_dbl, @floor_location )).to eq(@expected_output)
      end
      
      it "removes empty fields" do
        @floor_location = nil
        @expected_output.delete(:notes)
        expect(subject.to_h(@factory_dbl, @floor_location )).to eq(@expected_output)
      end
      it "removes nil fields" do
        @init[:collections_data] = [] 
        @expected_output.delete(:captionLink)
        expect(subject.to_h(@factory_dbl, @floor_location )).to eq(@expected_output)
      end
    end
  end
  context "multi-item holding" do
    before(:each) do
      @holding_record = double('Marc::Record')
      allow(@holding_record).to receive(:each_by_tag)
      @init = {
        holding: JSON.parse(File.read('./spec/fixtures/birds_alma_holding.json')),
        items: JSON.parse(File.read('./spec/fixtures/birds_alma_items.json'))["item"],
        collections_data: [],
        holding_record: @holding_record,
        bib: @bib_dbl
      }
    end
    context "notes" do
      #actually uses MARC gem to check for records
      it "returns summary_holdings found in holding MARC" do
        @init.delete(:holding_record)
        expect(described_class.new(**@init).notes(nil)).to eq(['1-24 : 1966/1967-2013'])
      end
    end
  end
  context "item with public_note" do
    before(:each) do
      @holding_record = double('Marc::Record')
      allow(@holding_record).to receive(:each_by_tag)
      @init = {
        holding: JSON.parse(File.read('./spec/fixtures/birds_alma_holding.json')),
        items: JSON.parse(File.read('./spec/fixtures/birds_alma_items.json'))["item"],
        collections_data: [],
        holding_record: @holding_record,
        bib: @bib_dbl
      }
    end
    context "notes" do
      #actually uses MARC gem to check for records
      it "returns summary_holdings found in holding MARC" do
        @init.delete(:holding_record)
        expect(described_class.new(**@init).notes(nil)).to eq(['1-24 : 1966/1967-2013'])
      end
      it "returns appropriate public_note found in holding MARC" do
        @init.delete(:holding_record)
        @init[:holding] = JSON.parse(File.read('./spec/fixtures/harleian_alma_holding.json'))
        expect(described_class.new(**@init).notes(nil)).to eq(['Additional vols. in Buhr, Analyzed 1-2:1-17, 2:18- Classed sep.'])
      end
    end
  end

end
describe Spectrum::AlmaItem, "to_a" do
  before(:each) do
    @item_dbl = instance_double(Spectrum::Item, status: 'On Shelf', call_number: 'call_number', can_request?: false)
    @action_dbl = instance_double(Spectrum::ItemAction, to_h: {foo: 'bar'})  
    @description_dbl = instance_double(Spectrum::ItemDescription, to_h: {text: 'N/A'})
    @bib_dbl = instance_double(Spectrum::BibRecord)
    @aleph = { intent: 'intent', icon: 'icon' }
    @to_a_init = {
      action: instance_double(Spectrum::ItemAction, to_h: {foo: 'bar'}),
      description: instance_double(Spectrum::ItemDescription, to_h: {text: 'N/A'}),
      intent: 'intent', icon: 'icon'
    }
  end
  subject do
    described_class.new(spectrum_item: @item_dbl, bib: @bib_dbl).to_a(**@to_a_init)
  end
  it "returns an array" do
    expect(subject.class.name).to eq('Array')
  end
  it "returns appropriate status" do
    expect(subject[2]).to eq( {text: 'On Shelf', intent: 'intent', icon: 'icon'}) 
  end
  it "returns call number" do
    expect(subject[3]).to eq( {text: @item_dbl.call_number}) 
  end
  it "handles Video call number" do
    allow(@item_dbl).to receive(:call_number).and_return('VIDEO call_number')
    array = described_class.new(item: { 'item_data' => {'inventory_number' => '12345'}}, spectrum_item: @item_dbl, bib: @bib_dbl).to_a(**@to_a_init)
    expect(array[3]).to eq( {text: 'VIDEO call_number - 12345'}
    ) 
  end
  it "handles empty call_number" do
    allow(@item_dbl).to receive(:call_number).and_return('')
    expect(subject[3]).to eq( {text: 'N/A'}) 
  end
  it "returns ItemAction hash for in first element" do
    expect(subject[0]).to eq(@action_dbl.to_h)
  end
  it "returns ItemDescription hash in second element" do
    expect(subject[1]).to eq(@to_a_init[:description].to_h)
  end
end

describe Spectrum::HathiHolding do
  context "default holding" do
    subject do
      described_class.new
    end
    it "returns appropriate heading" do
      expect(subject.headings).to eq(["Link","Description","Source"])
    end
    it "returns appropriate caption" do
      expect(subject.caption).to eq("HathiTrust Digital Library")
    end
    it "returns appropriate name" do
      expect(subject.name).to eq("HathiTrust Sources")
    end
    it "returns appropriate type" do
      expect(subject.type).to eq("electronic")
    end
  end
  context 'one item HathiTrust Holding' do
    before(:each) do
      @alma_response = JSON.parse(File.read('./spec/fixtures/alma_has_oclc.json'))
      @resp_dbl = double('HTTParty::Response', parsed_response: @alma_response, code: 200 )
      @alma_double = double('Spectrum::Utility::AlmaClient',get: @resp_dbl )
      direct_hathi_response = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
      #not doubling this because it's not the big an object and is actually what's used
      @hathi_response = Spectrum::Utility::HathiResponse.new([direct_hathi_response])
    end
    describe "to_h" do
      it "returns appropriate hash" do
        expected_hathi_holding_response= JSON.parse(File.read('./spec/fixtures/hurdy_gurdy_output.json'), symbolize_names: true)[0]
        hathi_holding = described_class.new(holding: @hathi_response, alma_client: @alma_double)
        expect(hathi_holding.to_h).to eq(expected_hathi_holding_response)
      end
    end
    describe "preExpanded" do
      it "returns true when initialized with preExpanded true" do
        hathi_holding = described_class.new(holding: @hathi_response, preExpanded: true, alma_client: @alma_double)
        expect(hathi_holding.preExpanded).to eq(true)
      end
      it "returns false when initialized with preExpanded false" do
        hathi_holding = described_class.new(holding: @hathi_response, preExpanded: false, alma_client: @alma_double)
        expect(hathi_holding.preExpanded).to eq(false)
      end
      it "returns false by default" do
        hathi_holding = described_class.new(holding: @hathi_response, alma_client: @alma_double)
        expect(hathi_holding.preExpanded).to eq(false)
      end
    end
    #describe "print_holding?" do
      #it "calls alma_client with oclc value" do
        #expect(@alma_double).to receive(:get).with("/bibs", {query: {other_system_id: "10543709", view: 'brief'}})
        #described_class.new(holding: @hathi_response,alma_client: @alma_double)
      #end
      #it "returns true if oclc found in alma" do
        #hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        #expect(hathi_item.print_holding?).to eq(true)
      #end
      #it "returns false if oclc not found" do
        #allow(@resp_dbl).to receive(:parsed_response).and_return({'total_record_count' => 0})
        #hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        #expect(hathi_item.print_holding?).to eq(false)
      #end
      #it "returns false if receives response error" do
        #allow(@resp_dbl).to receive(:code).and_return(400)
        #hathi_item = described_class.new(holding: @hathi_response,alma_client: @alma_double)
        #expect(hathi_item.print_holding?).to eq(false)
      #end
    #end
  end
end
describe Spectrum::HathiItem, "self.for" do
    before(:each) do
      pd_item_factory_dbl = lambda{|item| 'Spectrum::PublicDomainHathiItem'}
      etas_item_factory_dbl = lambda{|item| 'Spectrum::EtasHathiItem'}
      hathi_item_factory_dbl = lambda{|item| 'Spectrum::HathiItem'}
      @params = {item: JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))["items"][0],
                 ph_exists: false, 
                 pd_item_factory: pd_item_factory_dbl, 
                 etas_item_factory: etas_item_factory_dbl, 
                 hathi_item_factory: hathi_item_factory_dbl}
    end
    subject do 
      described_class.for(**@params)
    end
    it "returns array of EtasHathiItems for ic print holding" do
      @params[:ph_exists] = true
      expect(subject).to eq("Spectrum::EtasHathiItem")
    end
    it "returns array of HathiItems when not in umich catalogue" do
      @params[:ph_exists] = false
      expect(subject).to eq("Spectrum::HathiItem")
    end
    it "returns array of PublicDomainHathiItems when not in umich catalogue" do
      @params[:item]["rightsCode"] = 'pd'
      expect(subject).to eq("Spectrum::PublicDomainHathiItem")
    end
end
describe Spectrum::HathiItem, "to_a" do
  subject do
    hathi_resp = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
    described_class.new(hathi_resp['items'].first)
  end
  it "returns appropriate array" do
    expected_output = [
      {text: "Search only (no full text)", href: "https://hdl.handle.net/2027/inu.30000042758924",},
      {text: 'N/A'},
      {text: 'Indiana University'}
    ]
    expect(subject.to_a).to eq(expected_output)
  end
end
describe Spectrum::PublicDomainHathiItem, "to_a" do
  subject do
    hathi_resp = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
    described_class.new(hathi_resp['items'].first)
  end
  it "returns appropriate array" do
    expected_output = [
      {text: "Full text", href: "https://hdl.handle.net/2027/inu.30000042758924",},
      {text: 'N/A'},
      {text: 'Indiana University'}
    ]
    expect(subject.to_a).to eq(expected_output)
  end
end
describe Spectrum::EtasHathiItem, "to_a" do
  subject do
    hathi_resp = JSON.parse(File.read('./spec/fixtures/hurdy_hathi.json'))
    described_class.new(hathi_resp['items'].first)
  end
  it "returns appropriate array" do
    expected_output = [
      {text: "Full text available, simultaneous access is limited (HathiTrust log in required)", href: "https://hdl.handle.net/2027/inu.30000042758924?urlappend=%3Bsignon=swle:https://shibboleth.umich.edu/idp/shibboleth",},
      {text: 'N/A'},
      {text: 'Indiana University'}
    ]
    expect(subject.to_a).to eq(expected_output)
  end
end
