require 'digest/sha1'

module TopupService
  class IamaxAdapter < IamaxHttp

    Configuration = "#{RAILS_ROOT}/config/iamax.yml".freeze

    ## IAMAX API Topup Service integration is a 3-step process
    ## 1) checking retailer account balance using balcmd
    ## 2) doing topup for the given target mobile using topupcmd
    ## 3) follow up query to verify topup processed or not

    def initialize
      @config = config
    end
    
    def process_topup amount, mobile
      params = {
        :rcode => @config[:rcode],
        :uid => @config[:username]
      }

      check_account_balance(params, amount)
      trxn_no = process_topup_amount(amount, mobile, params)
      sleep 2
      check_topup_trxn_status(params, trxn_no)
    end

    ## Step 1 (Checking Account Balance)
    def check_account_balance params, amount
      params.merge!({
        :cmd => 'balcmd', 
        :pwd => password(@config[:rcode])
      })

      response = self.class.iamax_post(@config[:service_url], params)
      IamaxResponse.new(response.body).process_balcmd_response amount
    end

    ## Step 2 (Making Topup)
    def process_topup_amount amt, mobile, params = {}
      params.merge!({ 
        :cmd => 'topupcmd', 
        :target => mobile,
        :pwd => password(mobile, amt),
        :authcode => auth_code(mobile, amt, @config[:rcode]),
        :amt => amt
      })

      response = self.class.iamax_post(@config[:service_url], params)
      IamaxResponse.new(response.body).process_topupcmd_response
    end

    ## Step 3 (Follow up query to know status)
    def check_topup_trxn_status params, trxn_no
      params.merge!({ 
        :cmd => 'querybytrxncmd', 
        :pwd => password(trxn_no),
        :trxn => trxn_no
      })

      response = self.class.iamax_post(@config[:service_url], params)
      IamaxResponse.new(response.body).process_querybytrxncmd_response
    end
    
    private

    def auth_code *args
      Digest::SHA1.hexdigest(args.inject{|str, arg| str.to_s + arg.to_s}.downcase).downcase
    end
    
    def password *args
      s1 = @config[:username] + @config[:password]
      encrypted_pwd = Digest::SHA1.hexdigest(s1)
      s2 = encrypted_pwd.downcase + args.inject{|str, arg| str.to_s + arg.to_s}.downcase

      Digest::SHA1.hexdigest(s2).downcase
    end

    def config
      raise ConfigurationMissing,"#{Configuration} does not exist" unless File.file?(Configuration)
      YAML.load_file(Configuration).each_pair{|k,v| {k=>v.to_s.strip}}.symbolize_keys!
    end
  end
end
