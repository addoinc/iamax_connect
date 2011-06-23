require 'base64'
require 'httpclient'

module TopupService
  class IamaxHttp
    class << self
      
      def iamax_post(url, options = {})
        execute(url, options)
      end
      
      protected

      def execute(url, options = {})
        http = HTTPClient.new
        http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.post(url, options)

        if response.status == 200 
          return response
        else
          raise RuntimeError, "due to status #{response.status}, and content: #{response.content.strip}"
        end
      end

    end  
  end
end
