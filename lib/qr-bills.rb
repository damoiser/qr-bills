require 'i18n'
require 'qr-bills/qr-exceptions'
require 'qr-bills/qr-params'
require 'qr-bills/qr-html-layout'

class QRBills
  def initialize(qr_params)
    # init translator sets
    I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
    I18n.default_locale = :it

    bill = nil

    if qr_params.has_key?(:bill_type)

      if !QRParams.valid?(qr_params)
        raise QRExceptions::INVALID_PARAMETERS + ": params validation check failed"
      end

      if qr_params[:output_params][:format] == "html"
        bill = QRHTMLLayout.create(qr_params)
      else
        raise QRExceptions::NOT_SUPPORTED + ": html is the only output format supported so far"
      end

    else
      raise QRExceptions::INVALID_PARAMETERS + ": bill type param not set"
    end

    return bill
  end
end