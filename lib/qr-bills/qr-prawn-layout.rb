require 'qr-bills/qr-generator'

module QRPRAWNLayout
  def self.create(params)
    qrcode = QRGenerator.create(params, params[:qrcode_filepath])
    params[:qrcode_filepath] = convert_qrcode_to_data_url(qrcode)
    prawn_layout(params)
  end

  def self.convert_qrcode_to_data_url(qrcode)
    case qrcode
    when ChunkyPNG::Image
      qrcode.to_data_url
    else
      # Stolen from sprockets
      # https://github.com/rails/sprockets/blob/0f3e0e93dabafa8f3027e8036e40fd08902688c8/lib/sprockets/context.rb#L295-L303
      data = CGI.escape(qrcode)
      data.gsub!('%3D', '=')
      data.gsub!('%3A', ':')
      data.gsub!('%2F', '/')
      data.gsub!('%27', "'")
      data.tr!('+', ' ')

      "data:image/svg+xml;charset=utf-8,#{data}"
    end
  end

  def self.prawn_layout(params)
    I18n.with_locale(params[:bill_params][:language]) do
      layout  = "<div class=\"bill_container\">\n"
      layout += "  <div class=\"receipt_section\">\n"
      layout += "    <div class=\"title\">#{I18n.t("qrbills.receipt").capitalize}</div>\n"
      layout += "    <div class=\"subtitle payable_to\">#{I18n.t("qrbills.account").capitalize} / #{I18n.t("qrbills.payable_to").capitalize}</div>\n"
      layout += "    <div class=\"qrcontent\">\n"
      layout += "      #{params[:bill_params][:creditor][:iban]}<br/>\n"
      layout +=        render_address(params[:bill_params][:creditor][:address])
      layout += "    </div>\n"
      layout += "    <div><br/></div>\n"

      if !params[:bill_params][:reference].nil? && !params[:bill_params][:reference].empty?
        layout += "    <div class=\"subtitle reference\">#{I18n.t("qrbills.reference").capitalize}</div>\n"
        layout += "    <div class=\"reference\">\n"
        layout += "      #{params[:bill_params][:reference]}<br/>\n"
        layout += "    </div>\n"
        layout += "    <div><br/></div>\n"
      end

      layout += "    <div class=\"subtitle payable_by\">#{I18n.t("qrbills.payable_by").capitalize}</div>\n"
      layout += "    <div class=\"payable_by\">\n"
      layout +=        render_address(params[:bill_params][:debtor][:address])
      layout += "    </div>\n"

      layout += "    <div class=\"amount\">\n"
      layout += "      <div class=\"currency\">\n"
      layout += "        <span class=\"amount_header subtitle\">#{I18n.t("qrbills.currency").capitalize}</span><br/>\n"
      layout += "        #{params[:bill_params][:currency]}<br/>\n"
      layout += "      </div>\n"

      layout += "      <div class=\"amount_value\">\n"
      layout += "        <span class=\"amount_header subtitle\">#{I18n.t("qrbills.amount").capitalize}</span><br/>\n"
      layout += "        #{format('%.2f', params[:bill_params][:amount])}<br/>\n"
      layout += "      </div>\n"
      layout += "    </div>\n"

      layout += "    <div class=\"acceptance_point\">\n"
      layout += "      #{I18n.t("qrbills.acceptance_point").capitalize}<br/>\n"
      layout += "    </div>\n"

      layout += "  </div>\n"
      layout += "  <div class=\"payment_section\">\n"
      layout += "    <div class=\"left_column\">\n"
      layout += "      <div class=\"title\">#{I18n.t("qrbills.payment_part").capitalize}</div>\n"
      layout += "      <div class=\"qr_code\"><img src=\"#{params[:qrcode_filepath]}\" /></div>\n"
      layout += "      <div class=\"amount\">\n"
      layout += "        <div class=\"currency\">\n"
      layout += "          <span class=\"amount_header subtitle\">#{I18n.t("qrbills.currency").capitalize}</span><br/>\n"
      layout += "          #{params[:bill_params][:currency]}<br/>\n"
      layout += "        </div>\n"

      layout += "        <div class=\"amount_value\">\n"
      layout += "          <span class=\"amount_header subtitle\">#{I18n.t("qrbills.amount").capitalize}</span><br/>\n"
      layout += "          #{format('%.2f',params[:bill_params][:amount])}<br/>\n"
      layout += "        </div>\n"
      layout += "      </div>\n"

      layout += "      <div class=\"further_information\">\n"

      if !params[:bill_params][:bill_information_coded].nil? && !params[:bill_params][:bill_information_coded].empty?
        layout += "        <span class=\"finfo_header\">#{I18n.t("qrbills.name").capitalize} AV1:</span> #{params[:bill_params][:bill_information_coded]}\n"
      end

      if !params[:bill_params][:alternative_scheme_parameters].nil? && !params[:bill_params][:alternative_scheme_parameters].empty?
        layout += "        <span class=\"finfo_header\">#{I18n.t("qrbills.name").capitalize} AV2:</span> #{params[:bill_params][:alternative_scheme_parameters]}\n"
      end

      layout += "      </div>\n"
      layout += "    </div>\n"
      layout += "    <div class=\"right_column\">\n"
      layout += "      <div class=\"subtitle payable_to\">#{I18n.t("qrbills.account").capitalize} / #{I18n.t("qrbills.payable_to").capitalize}</div>\n"
      layout += "      <div class=\"qrcontent\">\n"
      layout += "        #{params[:bill_params][:creditor][:iban]}<br/>\n"
      layout +=          render_address(params[:bill_params][:creditor][:address])
      layout += "      </div>\n"
      layout += "    <div><br/></div>\n"

      if !params[:bill_params][:reference].nil? && !params[:bill_params][:reference].empty?
        layout += "    <div class=\"subtitle reference\">#{I18n.t("qrbills.reference").capitalize}</div>\n"
        layout += "      <div class=\"reference\">\n"
        layout += "        #{params[:bill_params][:reference]}<br/>\n"
        layout += "      </div>\n"
        layout += "    <div><br/></div>\n"
      end

      if !params[:bill_params][:additionally_information].nil? && !params[:bill_params][:additionally_information].empty?
        layout += "    <div class=\"subtitle additional_information\">#{I18n.t("qrbills.additional_information").capitalize}</div>\n"
        layout += "      <div class=\"additional_information\">\n"
        layout += "        #{params[:bill_params][:additionally_information]}<br/>\n"
        layout += "      </div>\n"
        layout += "    <div><br/></div>\n"
      end

      layout += "    <div class=\"subtitle payable_by\">#{I18n.t("qrbills.payable_by").capitalize}</div>\n"
      layout += "      <div class=\"payable_by\">\n"
      layout +=          render_address(params[:bill_params][:debtor][:address])
      layout += "      </div>\n"
      layout += "    </div>\n"
      layout += "  </div>\n"
      layout += "</div>\n"

      layout += "<style>\n"
      layout += "  @font-face{ \n"
      layout += "    font-family: \"liberation_sansregular\";\n"
      layout += "    src: url(\"#{params[:fonts][:eot]}\");\n"
      layout += "    src: url(\"#{params[:fonts][:eot]}?#iefix\") format(\"embedded-opentype\"),\n"
      layout += "        url(\"#{params[:fonts][:woff]}\") format(\"woff\"),\n"
      layout += "        url(\"#{params[:fonts][:ttf]}\") format(\"truetype\"),\n"
      layout += "        url(\"#{params[:fonts][:svg]}#liberation_sansregular\") format(\"svg\");\n"
      layout += "    font-weight: normal;\n"
      layout += "    font-style: normal;\n"
      layout += "  }\n"

      layout += "  .bill_container {\n"
      layout += "    width: 210mm;\n"
      layout += "    height: 105mm;\n"
      layout += "    font-family: \"liberation_sansregular\";\n"
      layout += "   border: 1px solid #ccc;\n"
      layout += "  }\n"

      layout += "  .bill_container:after {\n"
      layout += "    content: \"\";\n"
      layout += "    display: table;\n"
      layout += "    clear: both;\n"
      layout += "  }\n"

      layout += "  .receipt_section {\n"
      layout += "    width: 52mm;\n"
      layout += "    height: 95mm;\n"
      layout += "    padding: 5mm;\n"
      layout += "    float: left;\n"
      layout += "    font-size: 8pt;\n"
      layout += "    border-right: 1px dotted #ccc;\n"
      layout += "  }\n"

      layout += " .payment_section {\n"
      layout += "    width: 137mm;\n"
      layout += "    height: 95mm;\n"
      layout += "    float: left;\n"
      layout += "    padding: 5mm;\n"
      layout += "    font-size: 10pt;\n"
      layout += "  }\n"

      layout += "  .payment_section .left_column {\n"
      layout += "    height: 95mm;\n"
      layout += "    width: 46mm;\n"
      layout += "    float: left;\n"
      layout += "    margin-right: 5mm;\n"
      layout += "  }\n"

      layout += "  .payment_section .right_column {\n"
      layout += "    height: 95mm;\n"
      layout += "    width: 86mm;\n"
      layout += "    float: left;\n"
      layout += "  }\n"

      layout += "  .qr_code {\n"
      layout += "    padding: 5mm 0mm 5mm 0mm;\n"
      layout += "    height: 46mm;\n"
      layout += "    width: 46mm;\n"
      layout += "  }\n"

      layout += "  .qr_code img {\n"
      layout += "    height: 46mm;\n"
      layout += "    width: 46mm;\n"
      layout += "  }\n"

      layout += "  .amount {\n"
      layout += "    margin-top: 15px;\n"
      layout += "  }\n"

      layout += "  .amount .currency {\n"
      layout += "    float: left;\n"
      layout += "    margin-right: 15px;\n"
      layout += "  }\n"

      layout += "  .title {\n"
      layout += "    font-weight: bold;\n"
      layout += "    font-size: 11pt;\n"
      layout += "  }\n"

      layout += "  .receipt_section .subtitle {\n"
      layout += "    font-weight: bold;\n"
      layout += "    font-size: 6pt;\n"
      layout += "    line-height: 9pt;\n"
      layout += "  }\n"

      layout += "  .receipt_section .acceptance_point {\n"
      layout += "    font-weight: bold;\n"
      layout += "    text-align: right;\n"
      layout += "    font-size: 6pt;\n"
      layout += "    line-height: 8pt;\n"
      layout += "    padding-top: 5mm;\n"
      layout += "  }\n"

      layout += "  .payment_section .subtitle {\n"
      layout += "    font-weight: bold;\n"
      layout += "    font-size: 8pt;\n"
      layout += "    line-height: 11pt;\n"
      layout += "  }\n"

      layout += "  .payment_section .amount {\n"
      layout += "    height: 22mm;\n"
      layout += "    margin-top: 40px;\n"
      layout += "  }\n"

      layout += "  .payment_section .further_information {\n"
      layout += "    font-size: 7pt;\n"
      layout += "  }\n"

      layout += "  .payment_section .finfo_header {\n"
      layout += "    font-weight: bold;\n"
      layout += "  }      \n"
      layout += "</style>\n"

      layout
    end
  end

  def self.render_address(address)
    case address[:type]
    when 'S'
      format("%s<br>\n%s %s<br>\n%s %s<br>\n", address[:name], address[:line1], address[:line2], address[:postal_code], address[:town])
    when 'K'
      format("%s<br>\n%s<br>\n%s<br>\n", address[:name], address[:line1], address[:line2])
    end
  end
end
