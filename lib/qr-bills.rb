class QRBills

  # type of bills
  QR_BILL_WITH_QR_REFERENCE       = "orange_with_reference"
  QR_BILL_WITH_CREDITOR_REFERENCE = "red_with_reference"
  QR_BILL_WITOUTH_REFERENCE       = "red_without_reference"

  def initialize(qr_params)
    # init translator sets
    I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
    I18n.default_locale = :it

    if qr_params.has_key?(:bill_type)
      if qr_params[:bill_type] == QR_BILL_WITH_QR_REFERENCE

      elsif qr_params[:bill_type] == QR_BILL_WITH_CREDITOR_REFERENCE

      elsif qr_params[:bill_type] == QR_BILL_WITOUTH_REFERENCE

      else
        raise QRExceptions::INVALID_PARAMETERS + ": bill type not valid"
      end
    else
      raise QRExceptions::INVALID_PARAMETERS + ": bill type param not set"
    end
  end
end