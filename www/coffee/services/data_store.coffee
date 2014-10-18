gmApp.factory 'dataStore', ($rootScope, $localStorage, $q) ->


  _currentUser = {}
  _nearestDevice = null
  _previousDevice = null
  _hosts = null
  _currentHost = null

  $localStorage.ratings ||= {}

  $rootScope.currentUser = _currentUser

  _getHostById = (id) ->
    id = ~~id # convert to boolean
    for h in _hosts
      return h if h.business_id == id


  ########################################################################
  serviceObj = {}


  Object.defineProperties serviceObj,
    currentUser:
      enumerable: true
      get: -> _currentUser
      set: (value) -> _currentUser = value; $rootScope.currentUser = _currentUser

    nearestDevice:
      enumerable: true
      get: -> _nearestDevice
      set: (value) -> _nearestDevice = value

    previousDevice:
      enumerable: true
      get: -> _previousDevice
      set: (value) -> _previousDevice = value

    nearestDeviceUid:
      enumerable: true
      get: -> if _nearestDevice? then _nearestDevice.uid else null

    hosts:
      enumerable: true
      get: -> _hosts
      set: (value) -> _hosts = value ? null

    currentHost:
      enumerable: true
      get: -> _currentHost
      set: (value) -> _currentHost = value; $rootScope.currentHost = _currentHost

    ratings:
      enumerable: true
      get: -> $localStorage.ratings


    getHostById:
      enumerable: false
      get: -> _getHostById



  return serviceObj
