require 'httparty'

module VTiger
  class Poc
    include HTTParty

    def initialize(user_key)
      options = { query: { 'accessKey' => user_key, username: 'admin', operation: 'login' } }

      r = self.class.post('hedra.crm.netsac.com.br/webservice.php', options)
      byebug
    end
  end
end

HTTParty.get('http://hedra.crm.netsac.com.br/webservice.php?operation=getchallenge&username=admin')