class QRParams
  QR_BILL_WITH_QR_REFERENCE       = "orange_with_reference"
  QR_BILL_WITH_CREDITOR_REFERENCE = "red_with_reference"
  QR_BILL_WITOUTH_REFERENCE       = "red_without_reference"

  def self.get_qr_params
    {
      bill_type: "", # see global variables / README
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
        },
      },
      output_params: {
        format: "html"
      }
    }
  end

  def self.valid?(params)
    if params.has_key?(:bill_type)

      if !QRParams.base_params_valid?(params)
        return false
      end

      if params[:bill_type] == QR_BILL_WITH_QR_REFERENCE
        return QRParams.qr_bill_with_qr_reference_valid?(params)
      elsif qr_params[:bill_type] == QR_BILL_WITH_CREDITOR_REFERENCE
        return QRParams.qr_bill_with_creditor_reference_valid?(params)
      elsif qr_params[:bill_type] == QR_BILL_WITOUTH_REFERENCE
        return QRParams.qr_bill_without_reference_valid?(params)
      else
        return false
      end
    else
      return false
    end
  end

  def self.base_params_valid?(params)
    # todo
  end

  def self.qr_bill_with_qr_reference_valid?(params)
    # todo
  end

  def self.qr_bill_with_creditor_reference_valid?(params)
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

  def self.qr_bill_without_reference_valid?(params)
    # todo
    return true
  end
end