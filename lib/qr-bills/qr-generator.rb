# frozen_string_literal: true

require 'rqrcode'

module QRGenerator
  def self.create(params, qrcode_path = nil)
    format = params[:qrcode_format] || 'qrcode_png'

    case format
    when 'qrcode_png'
      build_qrcode_png(params[:bill_params], qrcode_path)
    when 'png'
      build_png(params[:bill_params])
    when 'svg'
      build_svg(params[:bill_params])
    else
      raise ArgumentError, "#{QRExceptions::NOT_SUPPORTED}: #{format} is not yet supported"
    end
  end

  def self.build_qrcode_png(bill_params, qrcode_path)
    warn('DEPRECATION WARNING: The qrcode_png format and qrcode_filepath parameter are deprecated and will be removed from qr-bills 1.1 (use png or svg instead)')

    final_qr = build_png(bill_params)
    final_qr.save(qrcode_path)
    final_qr
  end

  def self.build_png(bill_params)
    payload = build_payload(bill_params)
    qrcode = RQRCode::QRCode.new(payload, level: 'm')

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 0,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 10,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 1024
    )

    swiss_cross = ChunkyPNG::Image.from_file(File.expand_path("#{File.dirname(__FILE__)}/../../web/assets/images/swiss_cross.png"))
    png.compose!(swiss_cross, (png.width - swiss_cross.width) / 2, (png.height - swiss_cross.height) / 2)
  end

  def self.build_svg(bill_params)
    payload = build_payload(bill_params)
    qrcode = RQRCode::QRCode.new(payload, level: 'm')

    # Generate qr code
    svg_code = qrcode.as_svg(
      standalone: true, # return a svg wrapper
      viewbox: true, # return a viewBox so we can extract it
      module_size: 10,
      use_path: true
    )

    # Parse viewBox and calculate relative swiss cross size / center
    viewbox = svg_code.match(/viewBox="([\s\d]*)"/)[1]
    viewbox_size = viewbox.split(' ')[2].to_f
    swiss_cross_size = viewbox_size / (46.0 / 7.0)
    swiss_cross_center = (viewbox_size / 2.0) - (swiss_cross_size / 2.0)

    # Parse swiss cross and update size and coordinates
    svg_swiss_cross = File.open(File.expand_path("#{File.dirname(__FILE__)}/../../web/assets/images/swiss_cross.svg")).read
    svg_swiss_cross.gsub!('SWISS_CROSS_SIZE', swiss_cross_size.to_s)
    svg_swiss_cross.gsub!('SWISS_CROSS_CENTER', swiss_cross_center.to_s)

    # Assemble svg
    svg_code.gsub!(/<path/, '<g>\0')
    svg_code.gsub!(/<\/svg>/, "#{svg_swiss_cross}</g></svg>")

    # Optimize SVG for being URI-escaped
    # Stolen from Sprockets: https://github.com/rails/sprockets/blob/master/lib/sprockets/context.rb#L277-L293
    #
    # This only performs these basic but crucial optimizations:
    # * Removes comments, meta, doctype, and newlines.
    # * Replaces " with ', because ' does not need escaping.
    svg_code.gsub!(/<!--.*?-->|<\?.*?\?>|<!.*?>/m, '')
    svg_code.gsub!(/([\w:])="(.*?)"/, "\\1='\\2'")

    svg_code
  end

  # payload:
  #  "SPC\r\n" +    # indicator for swiss qr code: SPC (swiss payments code)
  #  "0200\r\n" +   # version of the specifications, 0200 = v2.0
  #  "1\r\n" +      # character set code: 1 = utf-8 restricted to the latin character set
  #  "CH4431999123000889012\r\n" +  # iban of the creditor (payable to)
  #  "S\r\n" +      # adress type: S = structured address, K = combined address elements (2 lines)
  #  "Robert Schneider AG\r\n" +    # creditor's name or company, max 70 characters
  #  "Via Casa Postale\r\n" +       # structured address: creditor's address street; combined address: address line 1 street and building number
  #  "1268/2/22\r\n" +              # structured address: creditor's building number; combined address: address line 2 including postal code and town
  #  "2501\r\n" +                   # creditor's postal code
  #  "Biel\r\n" +                   # creditor's town
  #  "CH\r\n" +                     # creditor's country
  #  "\r\n" +                       # optional: ultimate creditor's address type: S/K
  #  "\r\n" +                       # optional: ultimate creditor's name/company
  #  "\r\n" +                       # optional: ultimate creditor's street or address line 1
  #  "\r\n" +                       # optional: ultimate creditor's building number or address line 2
  #  "\r\n" +                       # optional: ultimate creditor's postal code
  #  "\r\n" +                       # optional: ultimate creditor's town
  #  "\r\n" +                       # optional: ultimate creditor's country
  #  "123949.75\r\n" +              # amount
  #  "CHF\r\n" +                    # currency
  #  "S\r\n"+                       # debtor's address type (S/K) (payable by)
  #  "Pia-Maria Rutschmann-Schnyder\r\n" +  # debtor's name / company
  #  "Grosse Marktgasse\r\n" +              # debtor's street or address line 1
  #  "28/5\r\n" +                           # debtor's building number or address line 2
  #  "9400\r\n" +                           # debtor's postal code
  #  "Rorschach\r\n" +                      # debtor's town
  #  "CH\r\n" +                             # debtor's country
  #  "QRR\r\n" +                            # reference type: QRR = QR reference, SCOR = Creditor reference, NON = without reference
  #  "210000000003139471430009017\r\n" +    # reference QR Reference: 27 chars check sum modulo 10 recursive, Creditor reference max 25 chars
  #  "Beachten sie unsere Sonderangebotswoche bis 23.02.2017!\r\n" + # additional information unstructured message max 140 chars
  #  "EPD\r\n" +                            # fixed indicator for EPD (end payment data)
  #  "//S1/10/10201409/11/181105/40/0:30\r\n" +   # bill information coded for automated booking of payment, data is not forwarded with the payment
  #  "eBill/B/41010560425610173";                 # alternative scheme paramaters, max 100 chars
  def self.build_payload(bill_params)
    payload = "SPC\r\n"
    payload += "0200\r\n"
    payload += "1\r\n"
    payload += "#{bill_params[:creditor][:iban].delete(' ')}\r\n"
    payload += "#{bill_params[:creditor][:address][:type]}\r\n"
    payload += "#{bill_params[:creditor][:address][:name]}\r\n"
    payload += "#{bill_params[:creditor][:address][:line1]}\r\n"
    payload += "#{bill_params[:creditor][:address][:line2]}\r\n"
    payload += "#{bill_params[:creditor][:address][:postal_code]}\r\n"
    payload += "#{bill_params[:creditor][:address][:town]}\r\n"
    payload += "#{bill_params[:creditor][:address][:country]}\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    if bill_params[:amount]
      payload += "#{format("%.2f", bill_params[:amount])}\r\n"
    else
      payload += "\r\n"
    end
    payload += "#{bill_params[:currency]}\r\n"
    payload += "#{bill_params.dig(:debtor, :address, :type)}\r\n"
    payload += "#{bill_params.dig(:debtor, :address, :name)}\r\n"
    payload += "#{bill_params.dig(:debtor, :address, :line1)}\r\n"
    payload += "#{bill_params.dig(:debtor, :address, :line2)}\r\n"
    payload += "#{bill_params.dig(:debtor, :address, :postal_code)}\r\n"
    payload += "#{bill_params.dig(:debtor, :address, :town)}\r\n"
    payload += "#{bill_params.dig(:debtor, :address, :country)}\r\n"
    payload += "#{bill_params[:reference_type]}\r\n"
    payload += "#{bill_params[:reference].delete(' ')}\r\n"
    payload += "#{bill_params[:additionally_information]}\r\n"
    payload += "EPD\r\n"
    payload += "#{bill_params[:bill_information_coded]}\r\n"
    payload += "#{bill_params[:alternative_scheme_parameters]}\r\n"
  end
end
