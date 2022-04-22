require 'qr-bills'

RSpec.describe QRBills do
  describe "init" do
    it "raise an exception if the bill kind is not set" do
      expect { QRBills.generate({}) }.to raise_error(ArgumentError, "QR-bill invalid parameters: bill type param not set")
    end

    it "raise an exception if currency is not set" do
      expect { QRBills.generate(bill_type: "bad") }.to raise_error(ArgumentError, "QR-bill invalid parameters: currency cannot be blank")
    end

    it "raise an exception if bill type is not supported" do
      expect { QRBills.generate(bill_type: "bad", bill_params: { currency: 'CHF' }) }.to raise_error(ArgumentError, "QR-bill invalid parameters: bill type is not supported")
    end
  end
end
