((that) ->

  SYMBOLS = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'
  MAPPING =
    'I': '1'
    'L': '1'
    'O': '0'

  _normalize = (text) ->
    return text.toUpperCase().replace(/[IL]/g, '1').replace(/O/g, '0').replace(new RegExp('[^' + SYMBOLS + ']', 'gi'), '')




  that.base32c =

    fromInt: (number) ->
      result = ''
      while number
        r = number % 32
        result = SYMBOLS[r] + result
        number = Math.floor(number / 32)
      return result

    toInt: (text) ->
      text = _normalize(text)
      total = 0
      for c in text
        total = total * 32 + SYMBOLS.indexOf(c)
      return total


)(this)
