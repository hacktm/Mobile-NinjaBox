gmApp.factory 'apiService', ($http, $rootScope, $q, $interval, $timeout, APP_CONFIG, EVENTS) ->
  _defaultHttpConfig =
    headers:
      'X-QRW-APP-KEY': APP_CONFIG.api_app_key

  _baseApiUrl = APP_CONFIG.api_base_url

  console.log("[api] base URL: #{_baseApiUrl}")

  _userToken = null

  _inErrorState = false


  # @return [$http promise]
  _httpGet = (path, config) ->
    httpConfig = angular.extend({}, _defaultHttpConfig, config)
    angular.extend(httpConfig.headers, { 'X-QRW-USER-TOKEN': _userToken })
    console.log("[api:get] #{path} % #{angular.toJson(httpConfig)}")
    $http.get(_baseApiUrl + path, httpConfig)
    .success (data) ->
      if ionic.Platform.isWebView()
        console.log '[api:recv] ' + angular.toJson(data)
      else
        console.log '[api:recv] ', data
    .error (data, status, headers, config) ->
      console.log "[api:get:error] #{status}: #{angular.toJson(data)}, headers: #{angular.toJson(headers)}"
      if not _inErrorState
        _inErrorState = true
        $rootScope.$broadcast EVENTS.NETWORK_ERROR, status, data


  # @return [$http promise]
  _httpPost = (path, data, config) ->
    httpConfig = angular.extend({}, _defaultHttpConfig, config)
    angular.extend(httpConfig.headers, { 'X-QRW-USER-TOKEN': _userToken })
    console.log("[api:post] #{path} (#{angular.toJson(data)}) % #{angular.toJson(httpConfig)}")
    $http.post(_baseApiUrl + path, data, httpConfig)
    .success (data) ->
      if ionic.Platform.isWebView()
        console.log '[api:recv] ' + angular.toJson(data)
      else
        console.log '[api:recv] ', data
    .error (data, status, headers, config) ->
      console.log "[api:post:error] #{status}: #{angular.toJson(data)}"
      if not _inErrorState
        _inErrorState = true
        $rootScope.$broadcast EVENTS.NETWORK_ERROR, status, data


  # @return [$q promise]
  _httpGetIgnoreStatus0 = (path, config) ->
    deferred = $q.defer()
    _httpGet(path, config)
    .success (data) ->
      deferred.resolve(data)
    .error (data, status) ->
      deferred.reject({ status: status, code: data.code, message: data.message, data: data }) if status != 0
    return deferred.promise


  # @return [$q promise]
  _httpPostIgnoreStatus0 = (path, postData, config) ->
    deferred = $q.defer()
    _httpPost(path, postData, config)
    .success (data) ->
      deferred.resolve(data)
    .error (data, status) ->
      deferred.reject({ status: status, code: data.code, message: data.message, data: data }) if status != 0
    return deferred.promise


  # @return [$q promise]
  _ftUpload = (path, imageURI) ->
    ft       = new FileTransfer()
    options  = new FileUploadOptions()
    deferred = $q.defer()

    options.fileKey     = "file"
    options.fileName    = imageURI.substr(imageURI.lastIndexOf('/')+1)
    options.mimeType    = "image/jpeg"
    options.chunkedMode = false
    options.headers     = angular.extend({}, _defaultHttpConfig.headers, { 'X-QRW-USER-TOKEN': _userToken })
    # Whatever you populate options.params with, will be available in req.body at the server-side.
    # options.params = 
    #   "description": "Uploaded from my phone"

    uploadSuccess = (data) -> 
      console.log '[CORDOVA] FileTransfer.upload() success', data
      deferred.resolve angular.fromJson(data.response)
    
    uploadFail = (error) -> 
      console.log '[CORDOVA] FileTransfer.upload() fail', error
      deferred.reject({ status: error.http_status, code: error.code, message: 'upload failed', data: error })

    ft.upload(imageURI, encodeURI(_baseApiUrl + path), uploadSuccess, uploadFail, options)
    
    return deferred.promise



  _networkCheck = (includeAuth = false) ->
    httpConfig = angular.extend({}, _defaultHttpConfig)
    if _userToken? && includeAuth
      withAuth = true
      angular.extend(httpConfig.headers, { 'X-QRW-USER-TOKEN': _userToken })
    else
      withAuth = false

    console.log('[api:ping] send auth:' + withAuth)

    $http.get(_baseApiUrl + '/ping', httpConfig)
    .success (data) ->
      console.log '[api:ping] ok: ' + angular.toJson(data)
      if _inErrorState
        _inErrorState = false
        $rootScope.$broadcast EVENTS.NETWORK_RECOVER, data.auth_ok
    .error (data, status) ->
      console.log "[api:ping] error: [#{status}] #{angular.toJson(data)}"
      if not _inErrorState
        _inErrorState = true
      $rootScope.$broadcast EVENTS.NETWORK_ERROR, status, data




  ############################################################

  serviceObj = {


    setUserToken: (userToken) ->
      _userToken = userToken if userToken?

    getUserToken: ->
      return _userToken




    networkCheck: ->
      deferred = $q.defer()
      _networkCheck(_userToken?)
      .success (data) ->
        if data.auth_ok is false
          # user local token present but server auth failed
          deferred.resolve('auth_failed')
        else if data.auth_ok is true
          # user local token present and server auth was ok
          deferred.resolve('auth_ok')
        else
          # user local token not present
          deferred.resolve('auth_required')
      .error (data, status) ->
        # network error
        deferred.reject({ status: status, data: data })
      return deferred.promise



    startPeriodicNetworkCheck: ->
      console.log('Start periodic network check')
      _periodicNetworkCheckInterval = $interval ->
        _networkCheck(false) if _inErrorState
      , 5000




    authSignup: (email, greetingName) ->
      return _httpPostIgnoreStatus0 '/auth/signup',
        email: email
        greeting_name: greetingName


    authResetPassword: (email) ->
      return _httpPostIgnoreStatus0 '/auth/reset_password',
        email: email


    authLogin: (email, password) ->
      return _httpPostIgnoreStatus0 '/auth/login',
        email: email
        password: password


    authLogout: ->
      return _httpGetIgnoreStatus0 '/auth/logout'



    checkin: (device_uid) ->
      return _httpGetIgnoreStatus0 '/checkin/' + device_uid
      


    updateProfile: (userData) ->
      return _httpPostIgnoreStatus0 '/account/profile', userData


    photoUpload: (imageURI) ->
      return _ftUpload '/account/profile/photo_upload', imageURI




    hosts: (latlng, device = null, subscribed = null) ->
      device = device.uid if device? && device.uid?
      return _httpGetIgnoreStatus0 '/businesses?latlng=' + latlng + (if subscribed then '&subscribed=1' else '' ) + (if device then '&device_uid=' + device else '')


    hostDetails: (hostId) ->
      return _httpGetIgnoreStatus0 '/businesses/' + hostId

    hostByDevice: (deviceUid) ->
      return _httpGetIgnoreStatus0 '/businesses/device/' + deviceUid


    hostSubscribe: (hostId) ->
      return _httpPostIgnoreStatus0 '/businesses/' + hostId + '/subscribe'


    hostUnsubscribe: (hostId) ->
      return _httpPostIgnoreStatus0 '/businesses/' + hostId + '/unsubscribe'


    rewardingOfferAnswer: (hostId, rewardingOfferId, data) ->
      return _httpPostIgnoreStatus0 '/businesses/' + hostId + '/rewarding_offers/' + rewardingOfferId + '/survey_answer', data


    rewardingOfferPhotoShare: (hostId, rewardingOfferId, data) ->
      return _httpPostIgnoreStatus0 '/businesses/' + hostId + '/rewarding_offers/' + rewardingOfferId + '/photo_share', data

  }


  return serviceObj
