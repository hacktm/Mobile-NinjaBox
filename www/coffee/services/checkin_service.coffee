gmApp.factory 'checkinService', ($rootScope, APP_CONFIG, EVENTS, apiService) ->


  CHECKIN_PAUSE_BETWEEN_REQUESTS = APP_CONFIG.checkin_between_requests_pause_milliseconds || 1000 * 60

  _initialized = false

  _deviceUid = null
  _lastCheckinSentAt = 0


  _sendCheckin = (device_uid) ->
    apiService.checkin(device_uid)
    .then (checkin_result) ->
      _lastCheckinSentAt = Date.now()


  _registerListenerForBleScanResult= ->
    $rootScope.$on EVENTS.BLE_SCAN_RESULT, (event, device) ->
      return unless device && device.uid?
      if device.uid != _deviceUid
        # always send a checkin when device changed
        _sendCheckin(device.uid)
        _deviceUid = device.uid
        return

      if _lastCheckinSentAt + CHECKIN_PAUSE_BETWEEN_REQUESTS < Date.now()
        _sendCheckin(device.uid)







  ########################################################################
  serviceObj = {
    initialize: ->
      return if _initialized
      _registerListenerForBleScanResult()
      _initialized = true
  }


  return serviceObj
