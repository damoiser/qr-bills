class QRParams
  QR_BILL_WITH_QR_REFERENCE       = "orange_with_reference"
  QR_BILL_WITH_CREDITOR_REFERENCE = "red_with_reference"
  QR_BILL_WITOUTH_REFERENCE       = "red_without_reference"

  def self.get_qr_params
    {
      bill_type: "", # see global variables / README
      qrcode_filepath: "", # where to store the qrcode, i.e. : /tmp/qrcode_1234.png
      fonts: {
        eot: "app/assets/fonts/LiberationSans-Regular.eot",
        woff: "app/assets/fonts/LiberationSans-Regular.woff",
        ttf: "app/assets/fonts/LiberationSans-Regular.ttf",
        svg: "app/assets/fonts/LiberationSans-Regular.svg",
      },
      bill_params: {
        language: "it",
        amount: 0.0,
        currency: "CHF",
        reference_type: "", # QRR = QR reference, SCOR = Creditor reference, NON = without reference
        reference: "", # qr reference or creditor reference (iso-11649)
        additionally_information: "",
        bill_information_coded: "",
        alternative_scheme_paramters: "",
        creditor: {
          address: {
            type: "S",
            name: "",
            line1: "",
            line2: "",
            postal_code: "",
            town: "",
            country: "",
            iban: ""
          },
        },
        debtor: {
          address: {
            type: "S",
            name: "",
            line1: "",
            line2: "",
            postal_code: "",
            town: "",
            country: "",
          },
        }
      },
      output_params: {
        format: "html"
      }
    }
  end

  def self.valid?(params)
    if params.has_key?(:bill_type)

      if !QRParams.base_params_valid?(params)
        return false
      end

      if params[:bill_type] == QR_BILL_WITH_QR_REFERENCE
        return QRParams.qr_bill_with_qr_reference_valid?(params)
      elsif params[:bill_type] == QR_BILL_WITH_CREDITOR_REFERENCE
        return QRParams.qr_bill_with_creditor_reference_valid?(params)
      elsif params[:bill_type] == QR_BILL_WITOUTH_REFERENCE
        return QRParams.qr_bill_without_reference_valid?(params)
      else
        return false
      end
    else
      return false
    end
  end

  def self.base_params_valid?(params)
    # todo
    return true
  end

  def self.qr_bill_with_qr_reference_valid?(params)
    # todo
    return true
  end

  def self.qr_bill_with_creditor_reference_valid?(params)
    # todo
    return true
  end

  def self.qr_bill_without_reference_valid?(params)
    # todo
    return true
  end
end