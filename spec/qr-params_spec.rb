require 'i18n'
require 'qr-bills/qr-params'

RSpec.configure do |config|
  config.before(:each) do
    I18n.default_locale = :it

    @params = QRParams.get_qr_params
    @params[:bill_type] = QRParams::QR_BILL_WITH_QR_REFERENCE
    @params[:fonts][:eot] = "../web/assets/fonts/LiberationSans-Regular.eot"
    @params[:fonts][:woff] = "../web/assets/fonts/LiberationSans-Regular.woff"
    @params[:fonts][:ttf] = "../web/assets/fonts/LiberationSans-Regular.ttf"
    @params[:fonts][:svg] = "../web/assets/fonts/LiberationSans-Regular.svg"
    @params[:locales][:path] = "config/locales/"
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
  end
end


RSpec.describe "QR params" do
  it "uses current locale as language" do
    expect(@params[:bill_params][:language]).to be :it
  end

  describe "basic param validation" do
    it "fails if bill type is empty" do
      @params[:bill_type] = ""
      expect{QRParams.base_params_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: bill type cannot be blank")
    end

    it "fails if bill type is nil" do
      @params[:bill_type] = nil
      expect{QRParams.base_params_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: bill type cannot be blank")
    end

    it "fails if currency type is empty" do
      @params[:bill_params][:currency] = ""
      expect{QRParams.base_params_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: currency cannot be blank")
    end

    it "fails if currency is nil" do
      @params[:bill_params][:currency] = nil
      expect{QRParams.base_params_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: currency cannot be blank")
    end

    it "succeeds if the previous params are correctly set" do
      expect{QRParams.base_params_valid?(@params)}.not_to raise_error
      expect(QRParams.base_params_valid?(@params)).to be_truthy
    end
  end

  describe "optional amount validation" do
    it "is valid when amount is nil (no predefined amount)" do
      @params[:bill_params][:amount] = nil
      expect{QRParams.amount_valid?(@params)}.not_to raise_error
      expect(QRParams.amount_valid?(@params)).to be_truthy
    end

    it "is valid when the amount key is entirely absent" do
      @params[:bill_params].delete(:amount)
      expect{QRParams.amount_valid?(@params)}.not_to raise_error
    end

    it "is valid with a classic decimal amount" do
      @params[:bill_params][:amount] = 12345.15
      expect{QRParams.amount_valid?(@params)}.not_to raise_error
    end

    it "is valid at the lower bound (0.01)" do
      @params[:bill_params][:amount] = 0.01
      expect{QRParams.amount_valid?(@params)}.not_to raise_error
    end

    it "is valid at the upper bound (999999999.99)" do
      @params[:bill_params][:amount] = 999_999_999.99
      expect{QRParams.amount_valid?(@params)}.not_to raise_error
    end

    it "rejects a zero amount" do
      @params[:bill_params][:amount] = 0
      expect{QRParams.amount_valid?(@params)}.to raise_error(ArgumentError, /amount must be nil.*or between 0.01 and 999999999.99/)
    end

    it "rejects a zero float amount" do
      @params[:bill_params][:amount] = 0.0
      expect{QRParams.amount_valid?(@params)}.to raise_error(ArgumentError, /amount must be nil.*or between 0.01 and 999999999.99/)
    end

    it "rejects a negative amount" do
      @params[:bill_params][:amount] = -5.0
      expect{QRParams.amount_valid?(@params)}.to raise_error(ArgumentError, /amount must be nil.*or between 0.01 and 999999999.99/)
    end

    it "rejects an amount above the maximum" do
      @params[:bill_params][:amount] = 1_000_000_000.00
      expect{QRParams.amount_valid?(@params)}.to raise_error(ArgumentError, /amount must be nil.*or between 0.01 and 999999999.99/)
    end

    it "is enforced through base_params_valid? too" do
      @params[:bill_params][:amount] = -1
      expect{QRParams.base_params_valid?(@params)}.to raise_error(ArgumentError, /amount must be nil.*or between 0.01 and 999999999.99/)
    end
  end

  describe "qr bill with QR reference params validation" do
    it "fails if reference is not QRR" do
      @params[:bill_params][:reference_type]= "bla"
      expect{QRParams.qr_bill_with_qr_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference type must be 'QRR' for QR bill with standard reference")
    end

    it "fails if reference is empty" do
      @params[:bill_params][:reference_type]= "QRR"
      @params[:bill_params][:reference] = ""
      expect{QRParams.qr_bill_with_qr_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference cannot be blank for QR bill with standard reference")
    end

    it "fails if reference is nil" do
      @params[:bill_params][:reference_type]= "QRR"
      @params[:bill_params][:reference] = nil
      expect{QRParams.qr_bill_with_qr_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference cannot be blank for QR bill with standard reference")
    end

    it "succeeds if the previous checks pass" do
      @params[:bill_params][:reference_type]= "QRR"
      expect{QRParams.qr_bill_with_qr_reference_valid?(@params)}.not_to raise_error
      expect(QRParams.qr_bill_with_qr_reference_valid?(@params)).to be_truthy
    end
  end

  describe "qr bill with creditor reference params validation" do
    it "fails if reference is not SCOR" do
      @params[:bill_params][:reference_type]= "bla"
      expect{QRParams.qr_bill_with_creditor_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference type must be 'SCOR' for QR bill with (new) creditor reference")
    end

    it "fails if reference is empty" do
      @params[:bill_params][:reference_type]= "SCOR"
      @params[:bill_params][:reference] = ""
      expect{QRParams.qr_bill_with_creditor_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference cannot be blank for QR bill with (new) creditor reference")
    end

    it "fails if reference is nil" do
      @params[:bill_params][:reference_type]= "SCOR"
      @params[:bill_params][:reference] = nil
      expect{QRParams.qr_bill_with_creditor_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference cannot be blank for QR bill with (new) creditor reference")
    end

    it "succeeds if the previous checks pass" do
      @params[:bill_params][:reference_type]= "SCOR"
      expect{QRParams.qr_bill_with_creditor_reference_valid?(@params)}.not_to raise_error
      expect(QRParams.qr_bill_with_creditor_reference_valid?(@params)).to be_truthy
    end
  end

  describe "qr bill with without reference params validation" do
    it "fails if reference is not NON" do
      @params[:bill_params][:reference_type]= "bla"
      expect{QRParams.qr_bill_without_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference type must be 'NON' for QR bill without reference")
    end

    it "fails if reference has a value" do
      @params[:bill_params][:reference_type]= "NON"
      @params[:bill_params][:reference] = "bla"
      expect{QRParams.qr_bill_without_reference_valid?(@params)}.to raise_error(ArgumentError, "QR-bill invalid parameters: reference must be blank for QR bill without reference")
    end

    it "succeeds if the previous checks pass" do
      @params[:bill_params][:reference_type]= "NON"
      @params[:bill_params][:reference] = ""
      expect{QRParams.qr_bill_without_reference_valid?(@params)}.not_to raise_error
      expect(QRParams.qr_bill_without_reference_valid?(@params)).to be_truthy
    end
  end
end
