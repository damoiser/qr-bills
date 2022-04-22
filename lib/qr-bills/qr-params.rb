module QRParams
  QR_BILL_WITH_QR_REFERENCE       = "orange_with_reference"
  QR_BILL_WITH_CREDITOR_REFERENCE = "red_with_reference"
  QR_BILL_WITHOUT_REFERENCE       = "red_without_reference"

  def self.get_qr_params
    {
      bill_type: "", # see global variables / README
      qrcode_format: nil, # png or svg, overwrites qrcode_filepath
      qrcode_filepath: "", # deprecated, where to store the qrcode, i.e. : /tmp/qrcode_1234.png
      fonts: {
        eot: File.expand_path("#{File.dirname(__FILE__)}/../../web/assets/fonts/LiberationSans-Regular.eot"),
        woff: File.expand_path("#{File.dirname(__FILE__)}/../../web/assets/fonts/LiberationSans-Regular.woff"),
        ttf: File.expand_path("#{File.dirname(__FILE__)}/../../web/assets/fonts/LiberationSans-Regular.ttf"),
        svg: File.expand_path("#{File.dirname(__FILE__)}/../../web/assets/fonts/LiberationSans-Regular.svg")
      },
      locales: {
        path: File.expand_path("#{File.dirname(__FILE__)}/../../config/locales")
      },
      bill_params: {
        language: I18n.locale,
        amount: 0.0,
        currency: "CHF",
        reference_type: "", # QRR = QR reference, SCOR = Creditor reference, NON = without reference
        reference: "", # qr reference or creditor reference (iso-11649)
        additionally_information: "",
        bill_information_coded: "",
        alternative_scheme_parameters: "",
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
    return false unless params.key?(:bill_type)
    return false unless QRParams.base_params_valid?(params)

    case params[:bill_type]
    when QRParams::QR_BILL_WITH_QR_REFERENCE
      QRParams.qr_bill_with_qr_reference_valid?(params)
    when QRParams::QR_BILL_WITH_CREDITOR_REFERENCE
      QRParams.qr_bill_with_creditor_reference_valid?(params)
    when QRParams::QR_BILL_WITHOUT_REFERENCE
      QRParams.qr_bill_without_reference_valid?(params)
    else
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: bill type is not supported"
    end
  end
  
  def self.base_params_valid?(params)
    if params[:bill_type] == "" || params[:bill_type] == nil
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: bill type cannot be blank"
    end

    if params.dig(:bill_params, :currency) == "" || params.dig(:bill_params, :currency) == nil
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: currency cannot be blank"
    end

    true
  end

  def self.qr_bill_with_qr_reference_valid?(params)
    if params[:bill_params][:reference_type] != "QRR"
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: reference type must be 'QRR' for QR bill with standard reference"
    end
    
    if params[:bill_params][:reference] == "" || params[:bill_params][:reference] == nil
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: reference cannot be blank for QR bill with standard reference"
    end

    true
  end

  def self.qr_bill_with_creditor_reference_valid?(params)
    if params[:bill_params][:reference_type] != "SCOR"
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: reference type must be 'SCOR' for QR bill with (new) creditor reference"
    end
    
    if params[:bill_params][:reference] == "" || params[:bill_params][:reference] == nil
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: reference cannot be blank for QR bill with (new) creditor reference"
    end

    true
  end

  def self.qr_bill_without_reference_valid?(params)
    if params[:bill_params][:reference_type] != "NON"
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: reference type must be 'NON' for QR bill without reference"
    end
    
    if params[:bill_params][:reference] != ""
      raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: reference must be blank for QR bill without reference"
    end
  
    true
  end
end
