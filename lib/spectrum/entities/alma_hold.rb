class Spectrum::Entities::AlmaHold
  def self.for(request: request)
    self.new(
      doc_id: request.doc_id,
      holding_id: request.holding_id,
      item_id: request.item_id,
      patron_id: request.patron_id,
      pickup_location: request.pickup_location,
      last_interest_date: request.not_needed_after
    )
  end

  def initialize(doc_id:, holding_id:, item_id:, patron_id:, pickup_location:, last_interest_date:)
    @doc_id = doc_id
    @holding_id = holding_id
    @item_id = item_id
    @patron_id = patron_id
    @pickup_location = pickup_location
    @last_interest_date = last_interest_date
    @client = AlmaRestClient.client
    @response = nil
  end

  def url
    "/bibs/#{@doc_id}/holdings/#{@holding_id}/items/#{@item_id}/requests?user_id=#{@patron_id}"
  end

  def body
    {
      "request_type" => "HOLD",
      "description" => "??",
      "holding_id" => holding_id,
      "pickup_location_type" => "LIBRARY",
      "pickup_location_library" => pickup_location,
      "pickup_location_circulation_desk" => "??",
      "pickup_location_institution" => "01UMICH_INST",
      "target_destination" => { "value" => "??" },
      "last_interest_date" => not_needed_after,
      "partial_digitization" => false,
      "chapter_or_article_title" => "??",
      "volume" => "??",
      "issue" => "??",
      "part" => "??",
      "date_of_publication" => "??",
      "chapter_or_article_author" => "??",
      "required_pages_range" => [ {
        "from_page" => "??", 
        "to_page" => "??"
      }],
      "full_chapter" => "??",
      "booking_start_date" => "??",
      "booking_end_date" => "??",
      "destination_location" => {"value" => "??" },
      "call_number_type" => {"value" => "1" },
      "call_number" => "1",
      "item_policy" => { "value" => "09" },
      "due_back_date" => "??",
      "copyrights_declaration_signed_by_patron" => false,
    }
  end

  def create!
    @response = @client.class.post(url, body: body)
    self
  end

  def error?
    return true if @response.status != 200
  end

  
end
