gmUtils =

  objType: (obj) ->
    if obj == undefined or obj == null
      return String obj
    classToType = {
      '[object Boolean]': 'boolean',
      '[object Number]': 'number',
      '[object String]': 'string',
      '[object Function]': 'function',
      '[object Array]': 'array',
      '[object Date]': 'date',
      '[object RegExp]': 'regexp',
      '[object Object]': 'object'
    }
    return classToType[Object.prototype.toString.call(obj)]




  email: (email) ->
    email = email.trim().toLowerCase() if email
    return email


  phoneNumberAsMsisdn: (phoneNumber) ->
    msisdn = phoneNumber.replace(/[^0-9]/g, '')
    if msisdn.length == 10
      msisdn = '1' + msisdn
    if msisdn.length != 11
      throw 'Invalid phone number'
    return msisdn


  macAddr: (deviceAddr) ->
    return deviceAddr.replace(/[^0-9a-f]/ig, '')


  isValidUSPhoneNumber: (phoneNumber) ->
    return phoneNumber && phoneNumber.replace(/[^0-9]/g, '').length == 10



  isValidEmail: (email) ->
    return email && email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)



  isValidText: (text, regexp) ->
    return text && text.match(regexp)



  isMinLengthText: (text, minLength) ->
    return text && text.trim().length >= (minLength || 1)

