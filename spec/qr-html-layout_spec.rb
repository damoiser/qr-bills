require 'i18n'
require 'fileutils'
require 'qr-bills/qr-html-layout'
require 'qr-bills/qr-params'

RSpec.configure do |config|
  config.before(:each) do
    @params = QRParams.get_qr_params
    @params[:fonts][:eot] = "../web/assets/fonts/LiberationSans-Regular.eot"
    @params[:fonts][:woff] = "../web/assets/fonts/LiberationSans-Regular.woff"
    @params[:fonts][:ttf] = "../web/assets/fonts/LiberationSans-Regular.ttf"
    @params[:fonts][:svg] = "../web/assets/fonts/LiberationSans-Regular.svg"
    @params[:locales][:path] = "config/locales/"
    @params[:qrcode_format] = 'png'
    @params[:bill_params][:creditor][:iban] = "CH9300762011623852957"
    @params[:bill_params][:creditor][:address][:type] = "S"
    @params[:bill_params][:creditor][:address][:name] = "Compagnia di assicurazione forma & scalciante"
    @params[:bill_params][:creditor][:address][:street_name]       = "Via cantonale"
    @params[:bill_params][:creditor][:address][:building_number]   = "24"  
    @params[:bill_params][:creditor][:address][:postal_code] = "3000"
    @params[:bill_params][:creditor][:address][:town] = "Lugano"
    @params[:bill_params][:creditor][:address][:country] = "CH"
    @params[:bill_params][:amount] = 12345.15
    @params[:bill_params][:currency] = "CHF"
    @params[:bill_params][:debtor][:address][:type] = "S"
    @params[:bill_params][:debtor][:address][:name] = "Foobar Barfoot"
    @params[:bill_params][:debtor][:address][:street_name]       = "Via Prospo"
    @params[:bill_params][:debtor][:address][:building_number]   = "25"
    @params[:bill_params][:debtor][:address][:postal_code] = "3001"
    @params[:bill_params][:debtor][:address][:town] = "Comano"
    @params[:bill_params][:debtor][:address][:country] = "CH"
    @params[:bill_params][:reference] = "RF89MTR81UUWZYO48NY55NP3"
    @params[:bill_params][:reference_type] = "SCOR"
    @params[:bill_params][:additionally_information] = "pagamento riparazione monopattino"

    I18n.load_path << File.join(@params[:locales][:path], "qrbills.it.yml")
    I18n.load_path << File.join(@params[:locales][:path], "qrbills.en.yml")
    I18n.load_path << File.join(@params[:locales][:path], "qrbills.de.yml")
    I18n.load_path << File.join(@params[:locales][:path], "qrbills.fr.yml")
    I18n.default_locale = :it
  end
end

RSpec.describe "QRHTMLLayout" do
  before do
    FileUtils.mkdir_p "#{Dir.pwd}/tmp/"
    File.delete filepath if File.exist?(filepath)
  end

  let(:filepath) { "#{Dir.pwd}/tmp/html-layout.html" }

  describe "layout generation" do
    before do
      @params[:qrcode_format] = 'png'
    end

    it "generates successfully the html layout + qr code" do
      expect{QRHTMLLayout.create(@params)}.not_to raise_error
    end

    it "generates legacy png qrcode" do
      @params[:qrcode_format] = nil
      @params[:qrcode_filepath] = "#{Dir.pwd}/tmp/qrcode-html.png"

      IO.binwrite("#{Dir.pwd}/tmp/html-layout.html", QRHTMLLayout.create(@params).to_s)
      expect(File.exist?(filepath)).to be_truthy
      expect(File.exist?("#{Dir.pwd}/tmp/qrcode-html.png")).to be_truthy
    end

    it "generates png qrcode" do
      html_output = QRHTMLLayout.create(@params).to_s
      IO.binwrite(filepath, html_output)
      expect(File.exist?(filepath)).to be_truthy

      expect(html_output).to include("data:image/png;base64,")
    end

    it "generates svg qrcode" do
      @params[:qrcode_format] = 'svg'

      html_output = QRHTMLLayout.create(@params).to_s
      IO.binwrite(filepath, html_output)
      expect(File.exist?(filepath)).to be_truthy

      expect(html_output).to include("data:image/svg+xml;charset=utf-8,")
    end

    it "does not overwrite locale" do
      @params[:bill_params][:language] = :de

      QRHTMLLayout.create(@params)

      expect(I18n.locale).to be :it
    end

    it "rounds correctly (1)" do
      html_output = QRHTMLLayout.create(@params).to_s

      IO.binwrite(filepath, html_output)
      expect(File.exist?(filepath)).to be_truthy

      expect(html_output).to include("12345.15")
    end

    it "rounds correctly (2)" do
      @params[:bill_params][:amount] = 12345.1

      html_output = QRHTMLLayout.create(@params).to_s

      IO.binwrite(filepath, html_output)
      expect(File.exist?(filepath)).to be_truthy

      expect(html_output).to include("12345.10")
    end

    it "rounds correctly (3)" do
      @params[:bill_params][:amount] = 12345.10

      html_output = QRHTMLLayout.create(@params).to_s

      IO.binwrite(filepath, html_output)
      expect(File.exist?(filepath)).to be_truthy

      expect(html_output).to include("12345.10")
    end
  end

  describe "optional amount (no predefined amount)" do
    before do
      @params[:qrcode_format] = 'png'
      @params[:bill_params][:amount] = nil
    end

    it "does not raise and does not print a numeric amount" do
      html_output = nil
      expect { html_output = QRHTMLLayout.create(@params).to_s }.not_to raise_error
      expect(html_output).not_to include("<br/>0.00")
    end

    it "renders a 40x15mm empty field with corner marks in the payment section" do
      html_output = QRHTMLLayout.create(@params).to_s

      expect(html_output).to include("payment_amount_blank")
      expect(html_output).to include("width: 40mm")
      expect(html_output).to include("height: 15mm")
    end

    it "renders a 30x10mm empty field with corner marks in the receipt section" do
      html_output = QRHTMLLayout.create(@params).to_s

      expect(html_output).to include("receipt_amount_blank")
      expect(html_output).to include("width: 30mm")
      expect(html_output).to include("height: 10mm")
    end

    it "draws the 4 corner registration marks at 0.75pt" do
      html_output = QRHTMLLayout.create(@params).to_s

      expect(html_output).to include("corner_tl")
      expect(html_output).to include("corner_tr")
      expect(html_output).to include("corner_bl")
      expect(html_output).to include("corner_br")
      expect(html_output).to include("0.75pt solid #000")
    end

    it "still shows currency and amount labels" do
      html_output = QRHTMLLayout.create(@params).to_s

      expect(html_output).to include(I18n.t("qrbills.currency").capitalize)
      expect(html_output).to include(I18n.t("qrbills.amount").capitalize)
    end
  end
end
