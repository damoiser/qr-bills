require 'qr-bills/qr-exceptions'

# implement Creditor Reference ISO 11649 generator
class QRCreditorReference
  PREFIX = "RF"

  @char_values = {
    "A": 10,
    "B": 11,
    "C": 12,
    "D": 13,
    "E": 14,
    "F": 15,
    "G": 16,
    "H": 17,
    "I": 18,
    "J": 19,
    "K": 20,
    "L": 21,
    "M": 22,
    "N": 23,
    "O": 24,
    "P": 25,
    "Q": 26,
    "R": 27,
    "S": 28,
    "T": 29,
    "U": 30,
    "V": 31,
    "W": 32,
    "X": 33,
    "Y": 34,
    "Z": 35
  }
  
  def self.create(reference)
    reference = reference.delete(' ')
    chars = reference.split('')

    if chars.size == 0 
      raise QRExceptions::INVALID_PARAMETERS + ": provided reference too short: must be at least one char"
    end

    # max 25 chars: 2 chars (RF) + 2 chars (check code) + 21 chars (reference)
    if chars.size > 21 
      raise QRExceptions::INVALID_PARAMETERS + ": provided reference too long: must be less than 21 chars"
    end

    reference_val = ""

    chars.each do |c|
      reference_val += get_char_value(c).to_s
    end

    # put RF+00 at the end to resolve check code
    reference_val += @char_values["R".to_sym].to_s + @char_values["F".to_sym].to_s + "00"

    # get check code
    check_code = 98 - (reference_val.to_i % 97)

    if check_code < 10
      check_code = "0" + check_code.to_s
    end

    return PREFIX + check_code.to_s + reference
  end

  def self.get_char_value(char)
    if char =~ /[0-9]/
      return char.to_i
    end

    return @char_values[char.upcase.to_sym]
  end
end
