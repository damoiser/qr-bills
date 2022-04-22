require 'i18n'
require 'qr-bills/qr-exceptions'
require 'qr-bills/qr-params'
require 'qr-bills/qr-html-layout'
require 'qr-bills/qr-creditor-reference'

module QRBills
  def self.generate(qr_params)
    raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: bill type param not set" unless qr_params.has_key?(:bill_type)
    raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: validation failed" unless QRParams.valid?(qr_params)

    # init translator sets
    %i[it en de fr].each do |locale|
      locale_file = File.join(qr_params[:locales][:path], "qrbills.#{locale}.yml")

      I18n.load_path << locale_file
    end

    output = case qr_params[:output_params][:format]
             when 'html'
               QRHTMLLayout.create(qr_params)
             else
               QRGenerator.create(qr_params, qr_params[:qrcode_filepath])
             end

    { params: qr_params, output: output }
  end

  def self.create_creditor_reference(reference)
    QRCreditorReference.create(reference)
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
    QRParams::QR_BILL_WITHOUT_REFERENCE
  end
end
