require 'i18n'
require 'qr-bills/qr-exceptions'
require 'qr-bills/qr-params'

class QRBills
  def initialize(qr_params)
    # init translator sets
    I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
    I18n.default_locale = :it

    bill = nil

    if qr_params.has_key?(:bill_type)

      if !QRParams.valid?(qr_params)
        raise QRExceptions::INVALID_PARAMETERS + ": invalid parameters"
      end

      if qr_params[:bill_type] == QRParams::QR_BILL_WITH_QR_REFERENCE
        # todo
      elsif qr_params[:bill_type] == QRParams::QR_BILL_WITH_CREDITOR_REFERENCE
        bill = QRGeneratorWithCreditorReference.new(params)
      elsif qr_params[:bill_type] == QRParams::QR_BILL_WITOUTH_REFERENCE
        bill = QRGeneratorWithoutReference.new(params)
      else
        raise QRExceptions::INVALID_PARAMETERS + ": bill type not valid"
      end
    else
      raise QRExceptions::INVALID_PARAMETERS + ": bill type param not set"
    end
    return bill
  end
end