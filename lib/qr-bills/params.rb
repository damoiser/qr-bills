class QRBills::Params

  def self.get_qr_params
    { 
      bill_params: {
        language: "it",
        qr_content: "",
        iban: "",
        address: {
          street: "",
          zip: "",
          city: "",
        },
        reference: "", # simple reference for orange slip, creditor reference (iso-11649) for the new red slip format
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
        }
      }
      output_params: {
        format: "html",
      }
    }
  end

  def self.red_slip_with_reference_valid?(params)
    if params[:iban].blank? ||
      params[:reference].blank? || 
      params[:currency].blank? || 
      params[:address].blank? || 
      params[:address][:street].blank? || 
      params[:address][:zip].blank? || 
      params[:address][:city].blank? || 
      params[:customer][:name].blank? || 
      params[:customer][:address].blank? || 
      params[:customer][:address][:street].blank? || 
      params[:customer][:address][:zip].blank? || 
      params[:customer][:address][:city].blank?
      return false
    end

    return true
  end

  def self.red_slip_valid?(params)
  end

  def self.orange_slip_valid?(params)
    # TODO
    return true
  end


end