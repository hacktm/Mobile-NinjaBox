gmApp.factory 'bleService', ($rootScope, $q, dataStore, APP_CONFIG, EVENTS) ->

  _ble = null
  _periodicScanStarted = false
  _nearestDevice = null
  _bleRequestInProgress = false




  _onBleScanResult = (device)->
    if device?
      #TODO: check if device has changed
      dataStore.previousDevice = dataStore.nearestDevice
      dataStore.nearestDevice = device
      _nearestDevice = device
      $rootScope.$broadcast EVENTS.BLE_SCAN_RESULT, device

    else # no device detected
      #TODO: better handle this (after number of scans, etc)
      if dataStore.nearestDevice != null  &&  dataStore.previousDevice != dataStore.nearestDevice
        dataStore.previousDevice = dataStore.nearestDevice
      dataStore.nearestDevice = null
      _nearestDevice = null

    $rootScope.$broadcast EVENTS.BLE_SCAN_CYCLE_COMPLETE







  ############
  ##

  initialize: ->
    if _ble == null
      if APP_CONFIG.ble_use_mock_service == true
        _ble = window.rewardingBleMock
      else
        if ionic.Platform.isWebView()
          if window.rewardingBle?
            _ble = window.rewardingBle
          else
            throw 'RewardingBle plugin not installed'
        else # not inside Cordova
          _ble = window.rewardingBleMock

    throw 'BLE Service can not be initialized: NotAuthenticated' unless dataStore.currentUser.consumerId?

    return false if _periodicScanStarted
    _periodicScanStarted = true

    console.log('[BLE] Periodic scan started.') if _BLE_LOG_LEVEL > 0

    _ble.initializeAndStartPeriodicScan (device)->

      console.log('[BLE] scan result: ' + angular.toJson(device)) if _BLE_LOG_LEVEL > 1
      _onBleScanResult(device)

    , (error) ->  # triggered on BLE error
      console.log '[BLE] ERROR: ' + angular.toJson(error) if _BLE_LOG_LEVEL > 0

    , dataStore.currentUser.consumerId



  resetBle: ->
    _ble.reset()
    # should wait at least 5 seconds



  startCheckout: (encdata1hex) ->
    console.log('bleService call: startCheckout()  allow=' + ! _bleRequestInProgress)
    deferred = $q.defer()
    if _bleRequestInProgress then deferred.reject('BLE[sendCheckoutRequest] failed. Another operation already in progress'); return deferred.promise
    _bleRequestInProgress = true
    #TODO: ensure 'currentUser.callName' is US-ASCII
    _ble.startCheckout ()->
      _bleRequestInProgress = false
      deferred.resolve()
    , (error) -> # fail
      #TODO: handle error better
      console.log('BLE sendCheckoutRequest error: ' + angular.toJson(error)) if _BLE_LOG_LEVEL > 0
      _bleRequestInProgress = false
      deferred.reject(error)
    , encdata1hex, dataStore.currentUser.greetingName
    return deferred.promise



  confirmPreviousTrx: (encdata1hex) ->
    console.log('bleService call: confirmPreviousTrx()  allow=' + ! _bleRequestInProgress)
    deferred = $q.defer()
    if _bleRequestInProgress then deferred.reject('BLE[sendCheckoutAccept] failed. Another operation already in progress'); return deferred.promise
    _bleRequestInProgress = true
    _ble.confirmPreviousTrx ()->  # payment method is always 0
      _bleRequestInProgress = false
      deferred.resolve()
    , (error) -> # fail
      #TODO: handle error better
      console.log('BLE sendCheckoutAccept error: ' + angular.toJson(error)) if _BLE_LOG_LEVEL > 0
      _bleRequestInProgress = false
      deferred.reject(error)
    , encdata1hex
    return deferred.promise

