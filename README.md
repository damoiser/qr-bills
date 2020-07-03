## Work in progress

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

### QR Bill "old red" with creditor reference (ISO-11649)
TODO

Expected output 
![QR Bill red without reference](https://github.com/damoiser/qr-bills/blob/master/imgs/qr_bill_red_with_credit_ref.jpeg)


### QR Bill "old red" without reference
TODO

Expected output  
![QR Bill red with creditor reference](https://github.com/damoiser/qr-bills/blob/master/imgs/qr_bill_red_no_ref.jpeg)


### QR Bill "old orange" with reference
TODO

Expected output  
![QR Bill orange with old reference](https://github.com/damoiser/qr-bills/blob/master/imgs/qr_bill_orange_old_ref.jpeg)

### QR Bill no amount
TODO

Expected output  
![QR Bill no amount](https://github.com/damoiser/qr-bills/blob/master/imgs/qr_bill_no_amount.jpeg)

## References
* https://www.paymentstandards.ch/dam/downloads/ig-qr-bill-en.pdf
* https://www.paymentstandards.ch/en/shared/know-how/faq/qr.html
* https://www.kmu.admin.ch/kmu/it/home/consigli-pratici/questioni-finanziarie/contabilita-e-revisione/introduzione-della-qr-fattura.html
* https://www.paymentstandards.ch/dam/downloads/drehbuch-rechnung-steller-empfaenger-it.pdf

## License
MIT