require 'qr-bills'
require 'qr-bills/qr-generator'

RSpec.describe "QRGenerator" do
  describe "qrcode generation" do
    it "generates successfully a qr image" do
      params = QRParams.get_qr_params
      params[:bill_params][:creditor][:iban] = "CH00 1234 5678 9101 2345 6"
      params[:bill_params][:creditor][:address][:type] = "S"
      params[:bill_params][:creditor][:address][:name] = "Compagnia di assicurazione forma & scalciante"
      params[:bill_params][:creditor][:address][:line1] = "Via cantonale"
      params[:bill_params][:creditor][:address][:line2] = "24"
      params[:bill_params][:creditor][:address][:postal_code] = "3000"
      params[:bill_params][:creditor][:address][:town] = "Lugano"
      params[:bill_params][:creditor][:address][:country] = "CH"
      params[:bill_params][:amount] = 12345.15
      params[:bill_params][:currency] = "CHF"
      params[:bill_params][:creditor][:iban] = "CH00 1234 5678 9101 2345 6"
      params[:bill_params][:debtor][:address][:type] = "S"
      params[:bill_params][:debtor][:address][:name] = "Foobar Barfoot"
      params[:bill_params][:debtor][:address][:line1] = "Via cantonale"
      params[:bill_params][:debtor][:address][:line2] = "25"
      params[:bill_params][:debtor][:address][:postal_code] = "3001"
      params[:bill_params][:debtor][:address][:town] = "Comano"
      params[:bill_params][:debtor][:address][:country] = "CH"
      params[:bill_params][:reference] = "SCOR"
      params[:bill_params][:reference_type] = "RF12 3456 7890 1234 ABCD DEFG HIJK"
      params[:bill_params][:additionally_information] = "pagamento riparazione monopattino"
      
      status = QRGenerator.create(params)
      expect(status).to be true
    end
  end
end