require 'qr-bills'
require 'qr-bills/qr-creditor-reference'

RSpec.describe "QRCreditorReference" do
  describe "checking the helpers" do
    it "works as expected" do
      expect(QRBills.create_creditor_reference("MTR81UUWZYO48NY55NP3")).to eq("RF89MTR81UUWZYO48NY55NP3")
    end
  end
  
  describe "validate the input correctly" do
    it "checks that reference should be less than 21 chars" do
      expect{QRCreditorReference.create("ABCDABCDABCDABCDABCDABCD")}.to raise_error
    end

    it "checks that reference should be greater or equal than 1 char" do
      expect{QRCreditorReference.create("")}.to raise_error
    end
  end

  describe "produce the correct reference" do
    it "produces the right one [1]" do
      expect(QRCreditorReference.create("MTR81UUWZYO48NY55NP3")).to eq("RF89MTR81UUWZYO48NY55NP3")
    end

    it "produces the right one [2]" do
      expect(QRCreditorReference.create("539007547034")).to eq("RF18539007547034")
    end

    it "produces the right one [3]" do
      expect(QRCreditorReference.create("539 007 5470 34 ")).to eq("RF18539007547034")
    end
  end
end