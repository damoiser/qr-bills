require 'qr-bills'

RSpec.describe QRBills do
  describe "init" do
    it "raise an exception if the bill kind is not set" do
      expect { QRBills.generate({}) }.to raise_error(ArgumentError, "QR-bill invalid parameters: bill type param not set")
    end

    it "raise an exception if the bill kind is not valid" do
      expect { QRBills.generate(bill_type: "bad") }.to raise_error(ArgumentError, "QR-bill invalid parameters: qrcode_filepath cannot be blank")
    end
  end
end