require 'rqrcode'
require 'RMagick'
include Magick


class QRGenerator
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
 
  def self.create(params, qrcode_path)
    create_qr(params, qrcode_path)
    add_swiss_cross(qrcode_path, qrcode_path)
  end

  def self.create_qr(params, qrcode_path)
    payload = "SPC\r\n"
    payload += "0200\r\n"
    payload += "1\r\n"
    payload += "#{params[:bill_params][:creditor][:iban]}\r\n"
    payload += "#{params[:bill_params][:creditor][:address][:type]}\r\n"
    payload += "#{params[:bill_params][:creditor][:address][:name]}\r\n"
    payload += "#{params[:bill_params][:creditor][:address][:line1]}\r\n"
    payload += "#{params[:bill_params][:creditor][:address][:line2]}\r\n"
    payload += "#{params[:bill_params][:creditor][:address][:postal_code]}\r\n"
    payload += "#{params[:bill_params][:creditor][:address][:town]}\r\n"
    payload += "#{params[:bill_params][:creditor][:address][:country]}\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "\r\n"
    payload += "#{params[:bill_params][:amount]}\r\n"
    payload += "#{params[:bill_params][:currency]}\r\n"
    payload += "#{params[:bill_params][:debtor][:address][:type]}\r\n"
    payload += "#{params[:bill_params][:debtor][:address][:name]}\r\n"
    payload += "#{params[:bill_params][:debtor][:address][:line1]}\r\n"
    payload += "#{params[:bill_params][:debtor][:address][:line2]}\r\n"
    payload += "#{params[:bill_params][:debtor][:address][:postal_code]}\r\n"
    payload += "#{params[:bill_params][:debtor][:address][:town]}\r\n"
    payload += "#{params[:bill_params][:debtor][:address][:country]}\r\n"
    payload += "#{params[:bill_params][:reference]}\r\n"
    payload += "#{params[:bill_params][:reference_type]}\r\n"
    payload += "#{params[:bill_params][:additionally_information]}\r\n"
    payload += "EPD\r\n"
    payload += "#{params[:bill_params][:bill_information_coded]}\r\n"
    payload += "#{params[:bill_params][:alternative_scheme_paramters]}\r\n"

    qrcode = RQRCode::QRCode.new(payload)

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
      size: 1024,
    )

    IO.binwrite(qrcode_path, png.to_s)
  end

  def self.add_swiss_cross(qrcode_path, final_path)
    qrImage =  Image.read(qrcode_path)[0]
    logoImage = Image.read("app/assets/images/swiss_cross.png")[0]
    finalImage = qrImage.composite(logoImage, CenterGravity, OverCompositeOp)
    finalImage.write(final_path)
  end
end