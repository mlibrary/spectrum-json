class JsonController < ApplicationController

  before_filter :init, :sample, :cors

  def cors
    headers['Access-Control-Allow-Origin'] = get_origin(request.headers)
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Referer'
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
    no_cache unless production?
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

  def text
    render(json: response_class.new(request_class.new(request)).spectrum)
  end

  def email
    render(json: response_class.new(request_class.new(request)).spectrum)
  end

  def file
    send_data(
      response_class.new(request_class.new(request)).data,
      type: 'application/x-research-info-systems',
      disposition: 'attachment',
      filename: 'Library Search Record Export.ris'
    )
  end

  def profile
    render(json: response_class.new(request_class.new(request)).spectrum)
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
    @specialists  = Spectrum::Response::Specialists.new(specialists)
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

  def hold_redirect
    @request = Spectrum::Request::PlaceHold.new(request)
    Spectrum::Response::PlaceHold.new(@request).renderable
    redirect_to 'https://www.lib.umich.edu/my-account/holds-recalls', status: 302
  end

  def hold
    @request = Spectrum::Request::PlaceHold.new(request)
    @response = Spectrum::Response::PlaceHold.new(@request)
    render(json: @response.renderable)
  end

  def holdings
    @request = Spectrum::Request::Holdings.new(request)
    @response = Spectrum::Response::Holdings.new(@source, @request)
    render(json: @response.renderable)
  end

  def get_this
    @request = Spectrum::Request::GetThis.new(request)
    @response = Spectrum::Response::GetThis.new(@source, @request)
    render(json: @response.renderable)
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

  def get_origin(headers)
    return headers['origin'] if headers['origin']
    return '*' unless headers['referer']
    uri = URI(request.headers['referer'])
    "#{uri.scheme}://#{uri.host}#{[80,443].include?(uri.port) ? '' : ':' + uri.port.to_s}"
  end

  def no_cache
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Mon, 01 Jan 1990 00:00:00 GMT'
  end

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
      data: engine.results.first,
      source: @source,
      focus: @focus,
    })
  end

  def specialists
    base_url.merge({
      request: @request,
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
      data: engine.results,
      source: @source,
      focus: @focus,
      total_available: engine.total_items,
      specialists: @specialists.spectrum
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

  # TODO: Move this into configuration.
  def default_institution
    addr = if request.env['REMOTE_ADDR'] != "127.0.0.1"
      request.env['REMOTE_ADDR']
    elsif request.env['HTTP_X_FORWARDED_FOR']
      request.env['HTTP_X_FORWARDED_FOR'].split(/ /).last
    else
      "127.0.0.1"
    end

    case IPAddr.new(addr)
    when IPAddr.new('35.0.0.0/16'),
         IPAddr.new('35.1.0.0/16'),
         IPAddr.new('35.2.0.0/16'),
         IPAddr.new('35.3.0.0/16'),
         IPAddr.new('67.194.0.0/16'),
         IPAddr.new('141.211.0.0/16'),
         IPAddr.new('141.212.0.0/16'),
         IPAddr.new('141.213.0.0/16'),
         IPAddr.new('141.214.0.0/16'),
         IPAddr.new('192.12.80.0/24'),
         IPAddr.new('198.108.8.0/21'),
         IPAddr.new('198.111.224.0/22'),
         IPAddr.new('198.111.181.0/25'),
         IPAddr.new('207.75.144.0/20'),
         IPAddr.new('10.0.0.0/8'),
         IPAddr.new('127.0.0.0/8'),
         IPAddr.new('172.16.0.0/12'),
         IPAddr.new('192.168.0.0/16')
      'U-M Ann Arbor Libraries'
    when IPAddr.new('141.216.0.0/16')
      'Flint Thompson Library'
    else
      'All Libraries'
    end
  end

  def basic_response
    {
      request:  @request.spectrum,
      response: @response.spectrum(filter_limit: -1),
      messages: @messages.map(&:spectrum),
      total_available: @response.total_available,
      default_institution: default_institution,
    }
  end

  def search_response
    {
      request:  @request.spectrum,
      response: @response.spectrum,
      messages: @messages.map(&:spectrum),
      total_available: @response.total_available,
      specialists: @specialists.spectrum,
      datastore: @datastore.spectrum,
      new_request: @new_request.spectrum
    }
  end

  def facet_response
    {
      request:  @request.spectrum,
      response: @response.spectrum,
      messages: @messages.map(&:spectrum),
      total_available: @response.total_available,
      datastore: @datastore.spectrum,
      new_request: @new_request.spectrum
    }
  end

  def request_class
    "Spectrum::Request::#{request.params[:type]}".constantize
  end

  def response_class
    "Spectrum::Response::#{request.params[:type]}".constantize
  end

  def production?
    begin
      request.env['SERVER_NAME'] == 'search.lib.umich.edu'
    rescue
      false
    end
  end
end
