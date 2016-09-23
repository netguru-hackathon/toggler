module Toggler
  module API
    class Connect
      attr_reader :api

      def initialize
        @api = TogglV8::API.new(get_token)
      end

      private

      def get_token
        ENV["TOGGLER_API_KEY"]
      end
    end
  end
end
