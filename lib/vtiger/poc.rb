require 'rest-client'
require 'digest'

module VTiger
  class LoginError < StandardError; end
  class Poc
    def initialize(username, user_key)
      @base_uri = 'http://hedra.crm.netsac.com.br/vtigercrm/webservice.php'
      @session_id = login(username, user_key)
    end

    def list_objs
      params = {operation: 'listtypes', sessionName: @session_id}
      JSON.parse(RestClient.get(@base_uri, params: params))
    end

    private
      def login(username, user_key)
        form = { operation: 'login', username: username, accessKey: create_access_key(username, user_key) }
        JSON.parse(RestClient.post(@base_uri, form))['result']['sessionName']
      end

      def token_for(username)
        opts = { params: { operation: 'getchallenge', username: username }, :accept => :json, :content_type => :json }
        res = JSON.parse(RestClient.get(@base_uri, opts))
        raise LoginError, 'Error to get token for log in.' if res["success"] != true || res['result']['token'].blank?

        res['result']['token']
      end

      def create_access_key(username, user_key)
        Digest::MD5.hexdigest(token_for(username) + user_key)
      end
  end
end
