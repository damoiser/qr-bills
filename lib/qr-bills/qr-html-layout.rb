class QRHTMLLayout

  def self.create(params)
    QRGenerator.create(params, params[:qrcode_filepath])
  end

  def html_layout
    layout = `
      <div class="bill_container">
        <div class="receipt">

        </div>
        <div class="

      </div>
      
      <style>
        
      </style>
      
      `


  end

end