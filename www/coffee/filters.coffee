gmApp.filter 'centsAsCurrency', () ->
  return (centsAmount, symbol = '$', showDecimals = true) ->
    amount = (centsAmount / 100).toFixed(2)
    strAmount = symbol + amount
#    if showDecimals && (amount % 1 == 0)
#      strAmount += '.00'
    return strAmount

gmApp.filter 'percentage', ->
  return (percentage) ->
    return (percentage / 100) + '%'

gmApp.filter 'daysBefore', ->
  return (date, days) ->
    d = new Date(date)
    d.setDate(d.getDate() - parseInt(days, 10))
    return d