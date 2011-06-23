module TopupService
  class IamaxResponse

    ## Process response got from Iamax API service.

    def initialize response
      @response = response
    end

    def process_balcmd_response topup
      if result_code.zero?
        raise LowTopupBalance if balance < topup
      else
        check_and_raise_exceptions
      end
    end

    def process_topupcmd_response
      case result_code
      when 0 then transaction_no
      when 4 then raise InvalidTargetMobile
      when 5 then raise InvalidAmount
      else
        check_and_raise_exceptions
      end
    end

    # Have to address status 'PENDING'
    def process_querybytrxncmd_response
      return true if status_code == 'APPROVED'
      raise TopupFailed if status_code == 'DECLINED'
      raise InvalidTransactionNo if result_code == 5
      raise NotAuthorized if result_code == 6
      check_and_raise_exceptions
      return false
    end
    
    def check_and_raise_exceptions 
      case result_code
      when 1 then raise InvalidCommand
      when 2 then raise InvalidRetailerCode
      when 3 then raise InvalidUsername
      when 4 then raise InvalidPassword
      when 5 then raise NotAuthorized
      when 6 then raise InvalidSaltPassword
      when 7 then raise InvalidAuthCode
      when 8 then raise NotAuthorized
      else
        raise TopupFailed
      end
    end

    private

    def result_code
      @response.match(/<ResultCode>(\d+)<\/ResultCode>/)[-1].to_i
    end

    def status_code
      @response.match(/<StatusCode>(\w+)<\/StatusCode>/)[-1] 
    end

    def transaction_no
      @response.match(/<TransactionNo>(\w+)<\/TransactionNo>/)[-1] 
    end

    def balance
      @response.match(/<Balance>(\d+)<\/Balance>/)[-1].to_i
    end
  end
end
