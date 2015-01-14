module RegexpExamples
  # Number of times to repeat for Star and Plus repeaters
  TIMES = 2

  # Maximum number of characters returned from a char set, to reduce output spam
  # For example:
  # If MaxGroupResults = 5, then
  # \d = [0, 1, 2, 3, 4]
  MaxGroupResults = 5

  module CharSets
    Lower = Array('a'..'z')
    Upper = Array('A'..'Z')
    Digit = Array('0'..'9')
    # 45.chr = "-". Need to make sure this is at the START of the array, or things break
    # This is because of the /[a-z]/ regex syntax, and how it's being parsed
    Punct = [45..45, 33..44, 46..47, 58..64, 91..96, 123..126].map { |r| r.map { |val| val.chr } }.flatten
    Hex   = Array('a'..'f') | Array('A'..'F') | Digit
    Any   = Lower | Upper | Digit | Punct
  end

  # Map of special regex characters, to their associated character sets
  BackslashCharMap = {
    'd' => CharSets::Digit,
    'D' => CharSets::Lower | CharSets::Upper | CharSets::Punct,
    'w' => CharSets::Lower | CharSets::Upper | CharSets::Digit | ['_'],
    'W' => CharSets::Punct.reject { |val| val == '_' },
    's' => [' ', "\t", "\n", "\r", "\v", "\f"],
    'S' => CharSets::Any - [' ', "\t", "\n", "\r", "\v", "\f"],
    'h' => CharSets::Hex,
    'H' => CharSets::Any - CharSets::Hex,

    't' => ["\t"], # tab
    'n' => ["\n"], # new line
    'r' => ["\r"], # carriage return
    'f' => ["\f"], # form feed
    'a' => ["\a"], # alarm
    'v' => ["\v"], # vertical tab
    'e' => ["\e"], # escape
  }
end

