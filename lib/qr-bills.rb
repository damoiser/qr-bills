class QRBills
  
  def get_qr_params
    { 
      language: "it",
      qr_content: "",
      iban: "",
      address: {
        street: "",
        zip: "",
        city: "",
      },
      reference: "",
      currency: "CHF",
      amount: 0.0,
      additionally_information: "",
      customer: {
        name: "",
        address: {
          street: "",
          zip: "",
          city: "",
        },
      },
    }
  end

  def self.create_orange_deposit_slip(qr_params)

  end

  def self.create_red_deposit_slip(qr_params)

  end

end