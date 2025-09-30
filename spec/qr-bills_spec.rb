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

    it "raise an exception if params for ESR is less than 26 chars" do
      expect { QRBills.create_esr_creditor_reference("123") }.to raise_error(ArgumentError, "QR-bill invalid parameters: You must provide a 26 digit reference for ESR.")
    end

    it "raise an exception if params for ESR is not an integer" do
      expect { QRBills.create_esr_creditor_reference("aabbccddeeffgghhiijjkkllmm") }.to raise_error(ArgumentError, "QR-bill invalid parameters: You must provide a valid digit for ESR.")
    end
  end
end
