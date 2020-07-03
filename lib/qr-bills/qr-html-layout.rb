class QRHTMLLayout

  def self.create(params)
    QRGenerator.create(params, params[:bill_params][:qrcode_filepath])
    return html_layout(params)
  end

  def self.html_layout(params)
    layout  = `<div class="bill_container">`
    layout += `  <div class="receipt_section">`
    layout += `    <div class="title">#{I18n.t(:receipt)}</div>`
    layout += `    <div class="subtitle payable_to">#{I18n.t(:account)} / #{I18n.t(:payable_to)}</div>`
    layout += `    <div class="content">`
    layout += `      #{params[:bill_params][:creditor][:iban]}<br/>`
    layout += `      #{params[:bill_params][:creditor][:name]}<br/>`
    layout += `      #{params[:bill_params][:creditor][:line1]} #{params[:bill_params][:creditor][:line2]}<br/>`
    layout += `      #{params[:bill_params][:creditor][:postal_code]} #{params[:bill_params][:creditor][:town]}<br/>`
    layout += `    </div>`
    layout += `    <div><br/></div>`

    if !params[:bill_params][:reference].blank?
    layout += `    <div class="subtitle reference">#{I18n.t(:reference)}</div>`
    layout += `    <div class="reference">`
    layout += `      #{params[:bill_params][:reference]}`
    layout += `    </div>`
    layout += `    <div><br/></div>`
    end

    layout += `    <div class="subtitle payable_by">#{I18n.t(:payable_by)}</div>`
    layout += `    <div class="payable_by">`
    layout += `      #{params[:bill_params][:debtor][:name]}<br/>`
    layout += `      #{params[:bill_params][:debtor][:line1]} #{params[:bill_params][:debtor][:line2]}<br/>`
    layout += `      #{params[:bill_params][:debtor][:postal_code]} #{params[:bill_params][:debtor][:town]}<br/>`
    layout += `    </div>`
    layout += ``
    layout += `    <div class="amount">`
    layout += `      <div class="currency">`
    layout += `        <span class="amount_header subtitle">#{I18n.t(:currency)}</span><br/>`
    layout += `        #{params[:bill_params][:currency]}`
    layout += `      </div>`
    layout += ``
    layout += `      <div class="amount_value">`
    layout += `        <span class="amount_header subtitle">#{I18n.t(:amount)}</span><br/>`
    layout += `        #{params[:bill_params][:amount]}`
    layout += `      </div>`
    layout += `    </div>`
    
    layout += `    <div class="acceptance_point">`
    layout += `      #{I18n.t(:acceptance_point)}`
    layout += `    </div>`
    
    layout += `  </div>`
    layout += `  <div class="payment_section">`
    layout += `    <div class="left_column">`
    layout += `      <div class="title">#{I18n.t(:payment_part)}</div>`
    layout += `      <div class="qr_code"><img src="#{params[:bill_params][:qrcode_filepath]}" /></div>`
    layout += `      <div class="amount">`
    layout += `        <div class="currency">`
    layout += `          <span class="amount_header subtitle">#{I18n.t(:currency)}</span><br/>`
    layout += `          #{params[:bill_params][:currency]}`
    layout += `        </div>`
    
    layout += `        <div class="amount_value">`
    layout += `          <span class="amount_header subtitle">#{I18n.t(:amount)}</span><br/>`
    layout += `          #{params[:bill_params][:amount]}`
    layout += `        </div>`
    layout += `      </div>`
    
    layout += `      <div class="further_information">`

    if !params[:bill_params][:bill_information_coded].blank?
    layout += `        <span class="finfo_header">Name AV1:</span> #{params[:bill_params][:bill_information_coded]}`
    end
  
    if !params[:bill_params][:alternative_scheme_paramters].blank?
    layout += `        <span class="finfo_header">Name AV2:</span> #{params[:bill_params][:alternative_scheme_paramters]}`
    end

    layout += `      </div>`
    layout += `    </div>`
    layout += `    <div class="right_column">`
    layout += `      <div class="subtitle payable_to">#{I18n.t(:account)} / #{I18n.t(:payable_to)}</div>`
    layout += `      <div class="content">`
    layout += `        #{params[:bill_params][:creditor][:iban]}<br/>`
    layout += `        #{params[:bill_params][:creditor][:name]}<br/>`
    layout += `        #{params[:bill_params][:creditor][:line1]} #{params[:bill_params][:creditor][:line2]}<br/>`
    layout += `        #{params[:bill_params][:creditor][:postal_code]} #{params[:bill_params][:creditor][:town]}<br/>`
    layout += `      </div>`
    layout += `    <div><br/></div>`

    if !params[:bill_params][:reference].blank?
    layout += `    <div class="subtitle reference">#{I18n.t(:reference)}</div>`
    layout += `      <div class="reference">`
    layout += `        #{params[:bill_params][:reference]}`
    layout += `      </div>`
    layout += `    <div><br/></div>`
    end

    if !params[:bill_params][:additionally_information].blank?
    layout += `    <div class="subtitle additional_information">#{I18n.t(:additional_information)}</div>`
    layout += `      <div class="additional_information">`
    layout += `        #{params[:bill_params][:additionally_information]}`
    layout += `      </div>`
    layout += `    <div><br/></div>`
    end

    layout += `    <div class="subtitle payable_by">#{I18n.t(:payable_by)}</div>`
    layout += `      <div class="payable_by">`
    layout += `        #{params[:bill_params][:debtor][:name]}<br/>`
    layout += `        #{params[:bill_params][:debtor][:line1]} #{params[:bill_params][:debtor][:line2]}<br/>`
    layout += `        #{params[:bill_params][:debtor][:postal_code]} #{params[:bill_params][:debtor][:town]}<br/>`
    layout += `      </div>`
    layout += `    </div>`
    layout += `  </div>`
    layout += `</div>`
  
    layout += `<style>`
    layout += `  @font-face{ `
    layout += `    font-family: 'liberation_sansregular';`
    layout += `    src: url('app/assets/fonts/LiberationSans-Regular.eot');`
    layout += `    src: url('app/assets/fonts/LiberationSans-Regular.eot?#iefix') format('embedded-opentype'),`
    layout += `        url('app/assets/fonts/LiberationSans-Regular.woff') format('woff'),`
    layout += `        url('app/assets/fonts/LiberationSans-Regular.ttf') format('truetype'),`
    layout += `        url('app/assets/fonts/LiberationSans-Regular.svg#liberation_sansregular') format('svg');`
    layout += `    font-weight: normal;`
    layout += `    font-style: normal;`
    layout += `  }`

    layout += `  .bill_container {`
    layout += `    width: 210mm;`
    layout += `    height: 105mm;`
    layout += `    font-family: 'liberation_sansregular';`
    layout += `   border: 1px solid #ccc;`
    layout += `  }`
    
    layout += `  .bill_container:after {`
    layout += `    content: "";`
    layout += `    display: table;`
    layout += `    clear: both;`
    layout += `  }`
    
    layout += `  .receipt_section {`
    layout += `    width: 52mm;`
    layout += `    height: 95mm;`
    layout += `    padding: 5mm;`
    
    layout += `    float: left;`
    
    layout += `    font-size: 8pt;`
    
    layout += `    border-right: 1px dotted #ccc;`
    layout += `  }`
    
    layout += ` .payment_section {`
    layout += `    width: 137mm;`
    layout += `    height: 95mm;`
    layout += `    float: left;`
    layout += `    padding: 5mm;`
    
    layout += `    font-size: 10pt;`
    layout += `  }`
    
    layout += `  .payment_section .left_column {`
    layout += `    height: 95mm;`
    layout += `    width: 46mm;`
    layout += `    float: left;`
    
    layout += `    margin-right: 5mm;`
    layout += `  }`
    
    layout += `  .payment_section .right_column {`
    layout += `    height: 95mm;`
    layout += `    width: 86mm;`
    layout += `    float: left;`
    layout += `  }`
    
    layout += `  .qr_code {`
    layout += `    padding: 5mm 0mm 5mm 0mm;`
    
    layout += `    height: 46mm;`
    layout += `    width: 46mm;`
    layout += `  }`
    
    layout += `  .qr_code img {`
    layout += `    height: 46mm;`
    layout += `    width: 46mm;`
    layout += `  }`
    
    layout += `  .amount {`
    layout += `    margin-top: 15px;`
    layout += `  }`
    
    layout += `  .amount .currency {`
    layout += `    float: left;`
    layout += `    margin-right: 15px;`
    layout += `  }`
    
    layout += `  .title {`
    layout += `    font-weight: bold;`
    layout += `    font-size: 11pt;`
    layout += `  }`
    
    layout += `  .receipt_section .subtitle {`
    layout += `    font-weight: bold;`
    layout += `    font-size: 6pt;`
    layout += `    line-height: 9pt;`
    layout += `  }`
    
    layout += `  .receipt_section .acceptance_point {`
    layout += `    font-weight: bold;`
    layout += `    text-align: right;`
    layout += `    font-size: 6pt;`
    layout += `    line-height: 8pt;`
    layout += `    padding-top: 5mm;`
    layout += `  }`
    
    layout += `  .payment_section .subtitle {`
    layout += `    font-weight: bold;`
    layout += `    font-size: 8pt;`
    layout += `    line-height: 11pt;`
    layout += `  }`
    
    layout += `  .payment_section .amount {`
    layout += `    height: 22mm;`
    layout += `  }`

    layout += `  .payment_section .further_information {`
    layout += `    font-size: 7pt;`
    layout += `  }`
    
    layout += `  .payment_section .finfo_header {`
    layout += `    font-weight: bold;`
    layout += `  }      `
    layout += `</style>`

    layout
  end
end