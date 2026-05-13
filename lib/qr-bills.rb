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

  # Given a creditor's IBAN number, this method checks whether an IBAN is of the new qr or the legacy esr type.
  # When generating a bill with a reference number, that number must be generated using the following method if this helper returns:
  #     - :qr => create_creditor_reference
  #     - :esr => create_esr_creditor_reference
  def self.iban_type(iban)
    return nil if iban.blank?
    iban_institute_identifier = iban.strip.gsub(' ', '')[4..8].to_i
    return iban_institute_identifier.between?(30_000, 31_999) ? :qr : :esr
  end

  def self.create_creditor_reference(reference)
    QRCreditorReference.create(reference)
  end

  # ESR reference should be considered "deprecated" and is here for backward compatibility
  # This is based on: http://sahits.ch/blog/blog/2007/11/08/uberprufen-esr-referenz-nummer/
  def self.create_esr_creditor_reference(reference)
    raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: You must provide a 26 digit reference for ESR." unless reference.size == 26
    raise ArgumentError, "#{QRExceptions::INVALID_PARAMETERS}: You must provide a valid digit for ESR." unless reference.to_i.to_s == reference

    esr = "#{reference}0"
    lookup_table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
    next_val = 0

    (0...esr.length - 1).each do |i|
      ch = esr[i]
      n = ch.to_i
      index = (next_val + n) % 10
      next_val = lookup_table[index]
    end

    result = (10 - next_val) % 10
    return result
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
