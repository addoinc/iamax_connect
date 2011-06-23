require "iamax/iamax_http"
require "iamax/iamax_adapter"
require "iamax/iamax_response"

module TopupService

  class TopupFailed < RuntimeError; end
  class ConfigurationMissing < RuntimeError; end
  class InvalidTargetMobile < TopupFailed; end
  class InvalidAmount < TopupFailed; end
  class InvalidCommand < TopupFailed; end
  class InvalidRetailerCode < TopupFailed; end
  class InvalidUsername < TopupFailed; end
  class InvalidPassword < TopupFailed; end
  class NotAuthorized < TopupFailed; end
  class InvalidTransactionNo < TopupFailed; end
  class InvalidSaltPassword < TopupFailed; end
  class InvalidAuthCode < TopupFailed; end
  class LowTopupBalance < TopupFailed; end

end
