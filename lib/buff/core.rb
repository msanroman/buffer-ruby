module Buff
  class Client
    module Core
      API_VERSION = "1"

      attr_reader :error_table

      def get(path, options={})
        params = set_params(options)
        response = self.class.get(path, params)
        interpret_response(response)
      end

      def interpret_response(response)
        case response.code
        when 200
          response
        else
          handle_response_code(response)
        end
      end


      def handle_response_code(response)
        error = Hashie::Mash.new( response.body )
        if ERROR_TABLE[error.code]
          error_explanation = "Buffer API Error Code: #{error.code}\n"
          error_explanation += "Description: #{error.error}"
        else
          error_explanation = "Buffer API Unknown Error in Response"
        end

        raise Buff::APIError, error_explanation
      end

      def self.error_table
        @error_table ||= ERROR_TABLE
      end

      ERROR_TABLE = {
         "403"=>"Permission denied.",
         "404"=>"Endpoint not found.",
         "405"=>"Method not allowed.",
         "1000"=>"An unknown error occurred.",
         "1001"=>"Access token required.",
         "1002"=>"Not within application scope.",
         "1003"=>"Parameter not recognized.",
         "1004"=>"Required parameter missing.",
         "1005"=>"Unsupported response format.",
         "1006"=>"Parameter value not within bounds.",
         "1010"=>"Profile could not be found.",
         "1011"=>"No authorization to access profile.",
         "1012"=>"Profile did not save successfully.",
         "1013"=>"Profile schedule limit reached.",
         "1014"=>"Profile limit for user has been reached.",
         "1015"=>"Profile could not be destroyed.",
         "1020"=>"Update could not be found.",
         "1021"=>"No authorization to access update.",
         "1022"=>"Update did not save successfully.",
         "1023"=>"Update limit for profile has been reached.",
         "1024"=>"Update limit for team profile has been reached.",
         "1025"=>"Update was recently posted, can't post duplicate content.",
         "1026"=>"Update must be in error status to requeue.",
         "1028"=>"Update soft limit for profile reached.",
         "1029"=>"Event type not supported.",
         "1030"=>"Media filetype not supported.",
         "1031"=>"Media filesize out of acceptable range.",
         "1032"=>"Unable to post image to LinkedIn group(s).",
         "1042"=>"User did not save successfully.",
         "1050"=>"Client could not be found.",
         "1051"=>"No authorization to access client."
      }

      def set_params(options)
        params = {}
        unless options.empty? || options.nil?
          params[:query] = options.merge auth_query
        else
          params[:query] = auth_query
        end
        return params
      end

    end
  end
end
