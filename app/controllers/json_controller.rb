class JsonController < ApplicationController

  before_filter :init, :sample, :cors

  def cors
    headers['Access-Control-Allow-Origin'] = request.headers['origin'] || '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    headers['Access-Control-Allow-Credentials'] = 'true'
    if request.method == 'OPTIONS'
      render :text => '', content_type: 'text/plain'
    end
  end

  def init
    @engine      = nil
    @response    = nil
    @messages    = []
    @focus       = Spectrum::Json.foci[params[:focus]]
    @source      = Spectrum::Json.sources[params[:source]]
  end

  def sample
    @messages << Spectrum::Response::Message.info(
      summary: "Information!",
      details: "You've been given a sample of an informational message."
    )
    @messages << Spectrum::Response::Message.success(
      summary: "Success",
      details: "A long-winded explanation for your success."
    )
    @messages << Spectrum::Response::Message.warn(
      summary: "Warning",
      details: "A long-winded explanation for your success."
    )
    @messages << Spectrum::Response::Message.error(
      summary: "Error",
      details: "Something went wrong with the doohickey."
    )
  end

  def index
    @request     = Spectrum::Request::Null.new
    @new_request = Spectrum::Request::Null.new
    @response    = Spectrum::Response::DataStoreList.new(list_datastores)
    render(json: basic_response)
  end

  def search
    @request      = Spectrum::Request::DataStore.new(request, @focus)
    @new_request  = Spectrum::Request::DataStore.new(request, @focus)
    @datastore    = Spectrum::Response::DataStore.new(this_datastore)
    @response     = Spectrum::Response::RecordList.new(fetch_records)
    render(json: search_response)
  end

  def facet
    @request      = Spectrum::Request::Facet.new(request)
    @new_request  = Spectrum::Request::Facet.new(request)
    @datastore    = Spectrum::Response::DataStore.new(this_datastore)
    @response     = Spectrum::Response::FacetList.new(fetch_facets)
    render(json: facet_response)
  end

  def record
    @request   = Spectrum::Request::Record.new(request)
    @datastore = Spectrum::Response::DataStore.new(this_datastore)
    if engine.total_items > 0
      @response  = Spectrum::Response::Record.new(fetch_record)
      render(json: record_response)
    else
      render(json: {}, status: 200)
    end
  end

  def holdings
    @request = Spectrum::Request::Holdings.new(request)
    @response = Spectrum::Response::Holdings.new(@source, @request)
    render(json: @response.to_a)
  end

  def holdings_response
    @response.spectrum
  end

  def record_response
    @response.spectrum
  end

  def show
    render json: "json#show"
  end

  def current_user
    nil
  end

  def bad_request
    render nothing: true, status: 400
  end

  def service_unavailable
    render nothing: true, status: 503
  end

  private

  def engine
    if @engine.nil?
      @engine = @source.engine(@focus, @request, self)
    end
    @engine
  end

  def list_datastores
    base_url.merge({
      data: Spectrum::Json.foci,
    })
  end

  def this_datastore
    base_url.merge({
      data: @focus.apply(@request, engine.search),
    })
  end

  def fetch_record
    base_url.merge({
      data: engine.documents.first,
      source: @source,
      focus: @focus,
    })
  end

  def fetch_holdings
    base_url.merge({
      data: @request.fetch_holdings,
      source: @source,
      focus: @focus,
    })
  end

  def fetch_records
    base_url.merge({
      data: engine.documents,
      source: @source,
      focus: @focus,
      total_available: engine.total_items,
    })
  end

  def fetch_facets
    base_url.merge({
      datastore: @datastore,
      source: @source,
      focus: @focus,
      facet: params[:facet],
      total_available: nil,
    })
  end

  def base_url
    { base_url: config.relative_url_root }
  end

  def basic_response
    {
      request:  @request.spectrum,
      response: @response.spectrum,
      messages: @messages.map(&:spectrum),
      total_available: @response.total_available
    }
  end

  def search_response
    basic_response.merge({
      datastore: @datastore.spectrum,
      new_request: @new_request.spectrum
    })
  end

  def facet_response
    basic_response.merge({
      datastore: @datastore.spectrum,
      new_request: @new_request.spectrum
    })
  end

end
