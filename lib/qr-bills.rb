require 'i18n'
require 'qr-bills/qr-exceptions'
require 'qr-bills/qr-params'
require 'qr-bills/qr-html-layout'
require 'qr-bills/qr-creditor-reference'

class QRBills
  def self.generate(qr_params)

    # params validation
    if qr_params.has_key?(:bill_type)

      if !QRParams.valid?(qr_params)
        raise QRExceptions::INVALID_PARAMETERS + ": params validation check failed"
      end

      if !qr_params[:output_params][:format] == "html"
        raise QRExceptions::NOT_SUPPORTED + ": html is the only output format supported so far"
      end

    else
      raise QRExceptions::INVALID_PARAMETERS + ": bill type param not set"
    end

    # init translator sets
    I18n.load_path << File.join(qr_params[:locales][:path], "it.yml")
    I18n.load_path << File.join(qr_params[:locales][:path], "en.yml")
    I18n.load_path << File.join(qr_params[:locales][:path], "de.yml")
    I18n.load_path << File.join(qr_params[:locales][:path], "fr.yml")
    I18n.default_locale = :it

    bill = { 
      params: qr_params,
      output: QRHTMLLayout.create(qr_params) 
    }

    return bill
  end

  def self.create_creditor_reference(reference)
    return QRCreditorReference.create(reference)
  end

  def self.get_qr_params
    QRParams.get_qr_params
  end

  def self.get_qrbill_with_qr_reference_type
    QRParams::QR_BILL_WITH_QR_REFERENCE
  end

  def self.get_qrbill_with_creditor_reference_type
    QRParams::QR_BILL_WITH_CREDITOR_REFERENCE
  end

  def self.get_qrbill_without_reference_type
    QRParams::QR_BILL_WITOUTH_REFERENCE
  end
end