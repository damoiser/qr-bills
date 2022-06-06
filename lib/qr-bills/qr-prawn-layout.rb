require 'qr-bills/qr-generator'
require 'prawn'
require 'prawn-svg'
require "prawn/measurement_extensions"

module QRPRAWNLayout
  attr_reader :document, :type

  def self.create(params, pdf = nil)
    qrcode = QRGenerator.create(params, params[:qrcode_filepath])
    params[:qrcode_filepath] = convert_qrcode_to_data_url(qrcode)
    prawn_layout(params, pdf)
  end

  def self.convert_qrcode_to_data_url(qrcode)
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

  def self.prawn_layout(params, pdf)
    pdf.canvas do
      I18n.with_locale(params[:bill_params][:language]) do
        pdf.bounding_box([0, 105.mm], width: 210.mm, height: 105.mm) do
          y_pos = pdf.cursor

          # Receipt Panel
          pdf.bounding_box([5.mm, y_pos], width: 52.mm, height: 105.mm) do
            pdf.move_down 5.mm

            pdf.text I18n.t("qrbills.receipt").capitalize, size: 11.pt, style: :bold
            pdf.move_down 4.mm

            pdf.text "#{I18n.t("qrbills.account").capitalize} / #{I18n.t("qrbills.payable_to").capitalize}", size: 6.pt, style: :bold
            pdf.text "#{params[:bill_params][:creditor][:iban]}", size: 8.pt
            pdf.text "#{render_address(params[:bill_params][:creditor][:address])}", size: 8.pt, inline_format: true

            if !params[:bill_params][:reference].nil? && !params[:bill_params][:reference].empty?
              pdf.move_down 4.mm
              pdf.text I18n.t("qrbills.reference").capitalize, size: 6.pt, style: :bold
              pdf.text "#{params[:bill_params][:reference]}", size: 8.pt
            end
            pdf.move_down 4.mm

            pdf.text I18n.t("qrbills.payable_by").capitalize, size: 6.pt, style: :bold
            pdf.text "#{render_address(params[:bill_params][:debtor][:address])}", size: 8.pt, inline_format: true
            pdf.move_down 8.mm

            bounding_box_cursor = pdf.cursor
            pdf.bounding_box([0, bounding_box_cursor], width: 20.mm) do
              pdf.text I18n.t("qrbills.currency").capitalize, size: 6.pt, style: :bold
              pdf.text "#{params[:bill_params][:currency]}", size: 8.pt
            end

            pdf.bounding_box([20.mm, bounding_box_cursor], width: 20.mm) do
              pdf.text I18n.t("qrbills.amount").capitalize, size: 6.pt, style: :bold
              pdf.text "#{format('%.2f', params[:bill_params][:amount])}", size: 8.pt
            end

            pdf.move_down 6.mm
            pdf.text I18n.t("qrbills.acceptance_point"), align: :right, size: 6.pt, style: :bold
          end

          # Payment Panel - QR code sub-section
          pdf.bounding_box([67.mm, y_pos], width: 51.mm, height: 90.mm) do
            pdf.move_down 5.mm

            pdf.text I18n.t("qrbills.payment_part").capitalize, size: 11.pt, style: :bold
            pdf.move_down 5.mm

            pdf.svg QRGenerator.build_svg(params[:bill_params]), width: 46.mm, height: 46.mm
            pdf.move_down 5.mm

            payment_currency_bounding_box_cursor = pdf.cursor
            pdf.bounding_box([0, payment_currency_bounding_box_cursor], width: 20.mm) do
              pdf.text I18n.t("qrbills.currency").capitalize, size: 8.pt, style: :bold
              pdf.text "#{params[:bill_params][:currency]}", size: 10.pt
            end

            pdf.bounding_box([20.mm, payment_currency_bounding_box_cursor], width: 20.mm) do
              pdf.text I18n.t("qrbills.amount").capitalize, size: 8.pt, style: :bold
              pdf.text "#{format('%.2f', params[:bill_params][:amount])}", size: 10.pt
            end
          end

          # Payment Panel - Account / Payable to sub-section
          pdf. bounding_box([118.mm, y_pos], width: 92.mm, height: 90.mm) do
            pdf.move_down 5.mm

            pdf.text "#{I18n.t("qrbills.account").capitalize} / #{I18n.t("qrbills.payable_to").capitalize}", size: 8.pt, style: :bold
            pdf.text "#{params[:bill_params][:creditor][:iban]}", size: 10.pt
            pdf.text "#{render_address(params[:bill_params][:creditor][:address])}", size: 10.pt, inline_format: true

            if !params[:bill_params][:reference].nil? && !params[:bill_params][:reference].empty?
              pdf.move_down 4.mm
              pdf.text "#{I18n.t("qrbills.reference").capitalize}", size: 8.pt, style: :bold
              pdf.text "#{params[:bill_params][:reference]}", size: 10.pt
            end

            if !params[:bill_params][:additionally_information].nil? && !params[:bill_params][:additionally_information].empty?
              pdf.move_down 4.mm
              pdf.text "#{I18n.t("qrbills.additional_information").capitalize}", size: 8.pt, style: :bold
              pdf.text "#{params[:bill_params][:additionally_information]}", size: 10.pt
            end
            pdf.move_down 4.mm

            pdf.text "#{I18n.t("qrbills.payable_by").capitalize}", size: 8.pt, style: :bold
            pdf.text "#{render_address(params[:bill_params][:debtor][:address])}", size: 10.pt, inline_format: true
          end

          # Payment Panel - Further information sub-section
          pdf.bounding_box([67.mm, y_pos - 85.mm], width: 138.mm, height: 10.mm) do
            if !params[:bill_params][:bill_information_coded].nil? && !params[:bill_params][:bill_information_coded].empty?
              pdf.text "<b>#{I18n.t("qrbills.name").capitalize}</b> AV1: #{params[:bill_params][:bill_information_coded]}", size: 7.pt, inline_format: true
            end

            if !params[:bill_params][:alternative_scheme_parameters].nil? && !params[:bill_params][:alternative_scheme_parameters].empty?
              pdf.text "<b>#{I18n.t("qrbills.name").capitalize}</b> AV2: #{params[:bill_params][:alternative_scheme_parameters]}", size: 7.pt, inline_format: true
            end
          end

          pdf.stroke_color("808080")
          pdf.dash(2, space: 2)
            pdf.stroke_vertical_line 0, 105.mm, at: 62.mm
            pdf.stroke_horizontal_line 0, 210.mm, at: 105.mm
          pdf.undash

        end
      end
    end
  end

  def self.render_address(address)
    case address[:type]
    when 'S'
      format("%s<br>%s %s<br>%s %s<br>", address[:name], address[:line1], address[:line2], address[:postal_code], address[:town])
    when 'K'
      format("%s<br>%s<br>%s<br>", address[:name], address[:line1], address[:line2])
    end
  end
end
