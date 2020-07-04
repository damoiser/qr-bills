[![Build Status](https://travis-ci.com/damoiser/qr-bills.svg?branch=master)](https://travis-ci.com/damoiser/qr-bills)

QR-Bills gem for implementing swiss payements.

## Notes
Please note that **no checks are peformed to validate IBAN and references (like Creditor Reference)**.
These checks are required to be perfomed by the running application.

## Installation
```
gem install qr-bills
```

Download and install the fonts on your application, default directory and fonts are:
```
eot: "app/assets/fonts/LiberationSans-Regular.eot"
woff: "app/assets/fonts/LiberationSans-Regular.woff"
ttf: "app/assets/fonts/LiberationSans-Regular.ttf"
svg: "app/assets/fonts/LiberationSans-Regular.svg"
```
The fonts can be edited in the ```qr_params```.

Liberation Sans is the only approved open source fonts (you can download for example [here](https://www.fontsquirrel.com/fonts/liberation-sans)). 

## Usage

```
# get the QR Params
params = QRBills.get_qr_params

# fill the params, for example
params[:qrcode_filepath] = "#{Dir.pwd}/tmp/qrcode-html.png"
params[:bill_params][:creditor][:iban] = "CH9300762011623852957"
params[:bill_params][:creditor][:address][:type] = "S"
params[:bill_params][:creditor][:address][:name] = "Compagnia di assicurazione forma & scalciante"
params[:bill_params][:creditor][:address][:line1] = "Via cantonale"
params[:bill_params][:creditor][:address][:line2] = "24"
params[:bill_params][:creditor][:address][:postal_code] = "3000"
params[:bill_params][:creditor][:address][:town] = "Lugano"
params[:bill_params][:creditor][:address][:country] = "CH"
params[:bill_params][:amount] = 12345.15
params[:bill_params][:currency] = "CHF"
params[:bill_params][:debtor][:address][:type] = "S"
params[:bill_params][:debtor][:address][:name] = "Foobar Barfoot"
params[:bill_params][:debtor][:address][:line1] = "Via cantonale"
params[:bill_params][:debtor][:address][:line2] = "25"
params[:bill_params][:debtor][:address][:postal_code] = "3001"
params[:bill_params][:debtor][:address][:town] = "Comano"
params[:bill_params][:debtor][:address][:country] = "CH"
params[:bill_params][:reference] = "RF89MTR81UUWZYO48NY55NP3"
params[:bill_params][:reference_type] = "SCOR"
params[:bill_params][:additionally_information] = "pagamento riparazione monopattino"

# generate the QR Bill
bill = QRBills.new(params)

# bill format is given in the params, standard is html
# bill has the following format: 
#    bill = { 
#      params: params,
#      output: "output" 
#    }

```


## References
* https://www.paymentstandards.ch/dam/downloads/ig-qr-bill-en.pdf
* https://www.paymentstandards.ch/en/shared/know-how/faq/qr.html
* https://www.kmu.admin.ch/kmu/it/home/consigli-pratici/questioni-finanziarie/contabilita-e-revisione/introduzione-della-qr-fattura.html
* https://www.paymentstandards.ch/dam/downloads/drehbuch-rechnung-steller-empfaenger-it.pdf

## License
MIT