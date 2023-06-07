module Api
  class GB
    def initialize
      @api_key = Setting.gb_api_key
    end

    def get(end_point, fields = {})
      @end_point = end_point
      @query = fields.merge(api_key: @api_key)
      resp = HTTParty.get("https://www.giantbomb.com/api/#{end_point}", query: @query)

      @uri = resp.request.last_uri.to_s
      @last_resp = resp.parsed_response['response'].deep_symbolize_keys
      return @last_resp
    end

    def next_page
      if @last_resp[:number_of_page_results].to_i == (@query[:limit] || 100)
        @query.merge!(offset: @last_resp[:offset].to_i + (@query[:limit] || 100))
        get(@end_point, @query)
      else
        { results: [] }
      end
    end
  end
end