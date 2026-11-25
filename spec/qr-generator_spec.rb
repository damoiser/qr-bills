require 'qr-bills'
require 'fileutils'
require 'qr-bills/qr-generator'

RSpec.describe QRGenerator do
  before do
    FileUtils.mkdir_p "#{Dir.pwd}/tmp/"
    File.delete filepath if File.exist?(filepath)
  end

  let(:filepath) { "#{Dir.pwd}/tmp/qrcode.png" }
  let(:params) do
    QRParams.get_qr_params.tap do |params_hash|
      params_hash[:bill_params][:creditor][:iban] = "CH93 0076 2011 6238 5295 7"
      params_hash[:bill_params][:creditor][:address][:type] = "S"
      params_hash[:bill_params][:creditor][:address][:name] = "Compagnia di assicurazione forma & scalciante"
      params_hash[:bill_params][:creditor][:address][:street_name]       = "Via cantonale"
      params_hash[:bill_params][:creditor][:address][:building_number]   = "24"  
      params_hash[:bill_params][:creditor][:address][:postal_code] = "3000"
      params_hash[:bill_params][:creditor][:address][:town] = "Lugano"
      params_hash[:bill_params][:creditor][:address][:country] = "CH"
      params_hash[:bill_params][:amount] = 12345.15
      params_hash[:bill_params][:currency] = "CHF"
      params_hash[:bill_params][:debtor][:address][:type] = "S"
      params_hash[:bill_params][:debtor][:address][:name] = "Foobar Barfoot"
      params_hash[:bill_params][:debtor][:address][:street_name]       = "Via Prospo"
      params_hash[:bill_params][:debtor][:address][:building_number]   = "25"
      params_hash[:bill_params][:debtor][:address][:postal_code] = "3001"
      params_hash[:bill_params][:debtor][:address][:town] = "Comano"
      params_hash[:bill_params][:debtor][:address][:country] = "CH"
      params_hash[:bill_params][:reference] = "RF89MTR81UUWZYO48NY55NP3"
      params_hash[:bill_params][:reference_type] = "SCOR"
      params_hash[:bill_params][:additionally_information] = "pagamento riparazione monopattino"
    end
  end

  describe "qrcode generation" do
    it "generates successfully a qr image" do
      params[:qrcode_format] = 'qrcode_png'

      expect(File.exist?(filepath)).to be_falsy
      expect{QRGenerator.create(params, filepath)}.not_to raise_error
      expect(File.exist?(filepath)).to be_truthy
    end

    it "generates a png image" do
      params[:qrcode_format] = 'png'

      png = QRGenerator.create(params)
      expect(png.class).to be(ChunkyPNG::Image)
    end

    it "generates a svg string" do
      params[:qrcode_format] = 'svg'

      svg = QRGenerator.create(params)
      File.write('tmp/qrcode.svg', svg)
      file = File.open('spec/fixtures/qrcode.svg').read
      expect(svg).to eq(file)
    end

    it "generates successfully the txt payload (and to test against SIX validator)" do
      txt = QRGenerator.build_payload(params[:bill_params])
      File.write('tmp/qrcode.txt', txt)
      file = File.open('spec/fixtures/qrcode.txt').read
      expect(txt).to eq(file)
    end

    it "optional fields are correctly generated as txt payload (and to test against SIX validator) > bill_information_coded" do
      params[:bill_params][:bill_information_coded] = "//S1/10/10201409/11/181105/40/0:30"
      
      txt = QRGenerator.build_payload(params[:bill_params])
      File.write('tmp/qrcode_information_coded.txt', txt)
      file = File.open('spec/fixtures/qrcode_information_coded.txt').read
      expect(txt).to eq(file)
    end

    it "optional fields are correctly generated as txt payload (and to test against SIX validator) > alternative_scheme_parameters" do
      params[:bill_params][:alternative_scheme_parameters] = "eBill/B/41010560425610173"
      
      txt = QRGenerator.build_payload(params[:bill_params])
      File.write('tmp/qrcode_information_alt_scheme.txt', txt)
      file = File.open('spec/fixtures/qrcode_information_alt_scheme.txt').read
      expect(txt).to eq(file)
    end

    it "optional fields are correctly generated as txt payload (and to test against SIX validator) > bill_information_coded & alternative_scheme_parameters" do
      params[:bill_params][:alternative_scheme_parameters] = "eBill/B/41010560425610173"
      params[:bill_params][:bill_information_coded] = "//S1/10/10201409/11/181105/40/0:30"

      txt = QRGenerator.build_payload(params[:bill_params])
      File.write('tmp/qrcode_information_coded_and_alt_scheme.txt', txt)
      file = File.open('spec/fixtures/qrcode_information_coded_and_alt_scheme.txt').read
      expect(txt).to eq(file)
    end
  end

  describe "optional amount (Amt, section 4.2.2 of the Swiss Implementation Guidelines)" do
    def lines(txt)
      txt.split("\r\n", -1)
    end

    it "keeps the classic amount-present payload byte-identical to before this change" do
      txt = QRGenerator.build_payload(params[:bill_params])
      file = File.open('spec/fixtures/qrcode.txt').read
      expect(txt).to eq(file)
    end

    it "encodes an empty (but present) Amt line when amount is nil, Ccy immediately following" do
      params[:bill_params][:amount] = nil

      txt = QRGenerator.build_payload(params[:bill_params])
      payload_lines = lines(txt)

      # Amt is at index 18, Ccy at index 19 - fixed positions per the payload layout
      # regardless of whether an amount is present.
      expect(payload_lines[18]).to eq("")
      expect(payload_lines[19]).to eq("CHF")
    end

    it "encodes an empty Amt line when the amount key is omitted entirely" do
      params[:bill_params].delete(:amount)

      txt = QRGenerator.build_payload(params[:bill_params])
      payload_lines = lines(txt)

      expect(payload_lines[18]).to eq("")
      expect(payload_lines[19]).to eq("CHF")
    end

    it "does not shift any other field when amount is nil (creditor/debtor/reference intact)" do
      params[:bill_params][:amount] = nil

      txt = QRGenerator.build_payload(params[:bill_params])
      payload_lines = lines(txt)

      expect(payload_lines[3]).to eq("CH9300762011623852957") # creditor IBAN
      expect(payload_lines[20]).to eq("S") # debtor address type
      expect(payload_lines[21]).to eq("Foobar Barfoot") # debtor name
      expect(payload_lines[27]).to eq("SCOR") # reference type
      expect(payload_lines[28]).to eq("RF89MTR81UUWZYO48NY55NP3") # reference
    end

    it "supports EUR with no predefined amount" do
      params[:bill_params][:amount] = nil
      params[:bill_params][:currency] = "EUR"

      txt = QRGenerator.build_payload(params[:bill_params])
      payload_lines = lines(txt)

      expect(payload_lines[18]).to eq("")
      expect(payload_lines[19]).to eq("EUR")
    end

    it "keeps formatting a real amount with 2 decimals as before" do
      params[:bill_params][:amount] = 42

      txt = QRGenerator.build_payload(params[:bill_params])
      payload_lines = lines(txt)

      expect(payload_lines[18]).to eq("42.00")
    end

    it "still works with a QRR reference and no predefined amount" do
      params[:bill_params][:amount] = nil
      params[:bill_params][:reference_type] = "QRR"
      params[:bill_params][:reference] = "210000000003139471430009017"

      txt = QRGenerator.build_payload(params[:bill_params])
      payload_lines = lines(txt)

      expect(payload_lines[18]).to eq("")
      expect(payload_lines[27]).to eq("QRR")
      expect(payload_lines[28]).to eq("210000000003139471430009017")
    end

    it "still works with a NON reference (no reference) and no predefined amount" do
      params[:bill_params][:amount] = nil
      params[:bill_params][:reference_type] = "NON"
      params[:bill_params][:reference] = ""

      txt = QRGenerator.build_payload(params[:bill_params])
      payload_lines = lines(txt)

      expect(payload_lines[18]).to eq("")
      expect(payload_lines[27]).to eq("NON")
      expect(payload_lines[28]).to eq("")
    end
  end
end
