class JanboController <  ApplicationController
  before_filter :init

  def init
    @json = JsonController.new
    @json.instance_eval do
      @messages = []
      @response = Spectrum::Response::Base.new
    end
  end

  def index
    ret = <<EOF
<html>
  <head></head>
  <body>
    <ul>
      <li><a href="/testapp/p9500/janbo/1">Test 1: Website Search</a></li>
      <li><a href="/testapp/p9500/janbo/2">Test 2: Mirlyn Search</a></li>
      <li><a href="/testapp/p9500/janbo/3">Test 3</a></li>
      <li><a href="/testapp/p9500/janbo/4">Test 4</a></li>
    </ul>
  </body>
</html>
EOF
    render html: ret.html_safe
  end

  def show
    send ("show_" + params[:id].to_i.to_s).to_sym
  end

  def show_1
    setup_source('website')
    setup_datastore_request(fake_request)
    run_search
    
    render(json: @json.instance_eval { search_response })
  end

  def show_2

    setup_source('mirlyn')
    setup_datastore_request(fake_request)
    run_search
    
    render(json: @json.instance_eval { search_response })
  end

  def run_search
    @json.instance_eval do
      @response  = Spectrum::Response::RecordList.new(fetch_records)
    end
  end

  def setup_datastore_request(request)
    @json.instance_exec(request) do |request|
      @request = Spectrum::Request::DataStore.new(request)
      @new_request = @request
    end
  end

  def setup_source(uid)
    @json.instance_exec(uid) do
      @source_id = uid
      @focus  = Spectrum::Json.foci[uid]
      @source = Spectrum::Json.sources[uid]
      @datastore = Spectrum::Response::DataStore.new(this_datastore)
    end
  end

  def empty_records
    data = []
    { data: data }
  end

  def fake_datastore
    data = case params[:id].to_i
    when 2
      Spectrum::Json.foci['website']
    end
    { data: data }
  end

  def fake_request
    req = FakeRequest.new
    case params[:id].to_i
    when 1
      req.raw_post = <<-EOF
{
  "uid": "website",
  "start": 0,
  "count": 10,
  "field_tree": {
    "type": "field_boolean",
    "value": "AND",
    "children": [
      {
        "type": "literal",
        "value": "hello"
      },
      {
        "type": "special",
        "value": "hello"
      }
    ]
  },
  "facets": {},
  "sort": "relative",
  "settings": {}
}
      EOF
    when 2
      req.raw_post = <<-EOF
{
  "uid": "mirlyn",
  "start": 0,
  "count": 10,
  "field_tree": {
    "type": "field_boolean",
    "value": "AND",
    "children": [
      {
        "type": "literal",
        "value": "science"
      }
    ]
  },
  "facets": {},
  "sort": "relative",
  "settings": {}
}

      EOF
    end
    req
  end

  class FakeRequest
    attr_accessor :raw_post
    def initialize
      @post = true
    end

    def post?
      @post
    end
  end

  private
  def current_user
    nil
  end
end
