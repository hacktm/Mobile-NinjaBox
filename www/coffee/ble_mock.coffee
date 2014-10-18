window._DEVICE_UID = 1

window.rewardingBleMock = (->

  _device_state = 0
  _device_consumerId = null
  _device_operation = -1
  _encdata2hex = null

  _my_consumerId = null


  _deviceFactory = () ->
    return {
      address: 'ff:ff:ff:ff:ff:01'
      rssi: -41
      uid: _DEVICE_UID
      state: _device_state
      encdatahex: _encdata2hex
    }



  #------------------------------------- mock functions ---------------

  _scannedDeviceData = ->
    _deviceFactory()


  #--------------------------------------------------------------------

  return {

    initializeAndStartPeriodicScan: (onScanCycleFinished, onFail, consumerId) ->
      _my_consumerId = consumerId

      console.log('[BLEMOCK] .initializeAndStartPeriodicScan()') if _BLE_LOG_LEVEL > 0

      cycleCount = 0
      setTimeout ->
        cycleCount += 1
        console.log('[BLEMOCK] .onScanCycleFinished() - cycle: ' + cycleCount) if _BLE_LOG_LEVEL > 1
        onScanCycleFinished(_scannedDeviceData())
      , 1000

      setInterval ->
        cycleCount += 1
        console.log('[BLEMOCK] .onScanCycleFinished() - cycle: ' + cycleCount) if _BLE_LOG_LEVEL > 1
        onScanCycleFinished(_scannedDeviceData())
      , 2000




    startCheckout: (onSuccess, onFail, consumerName, encdata1hex) ->
      console.log('[BLEMOCK] .startCheckout(' + consumerName + ', ' + encdata1hex + ')') if _BLE_LOG_LEVEL > 0
      _my_consumerName = consumerName
      _device_consumerId = _my_consumerId
      _device_state = 1
#      _device_operation = encdata1hex[21]
      setTimeout ->
        onSuccess()
        #TODO: set new advertising data
      , 500



    confirmPreviousTrx: (onSuccess, onFail, encdata1hex) ->
      console.log('[BLEMOCK] .confirmPreviousTrx(' + encdata1hex + ')') if _BLE_LOG_LEVEL > 0
      setTimeout ->
        _device_state = 0
        onSuccess()
      , 500


  }


)()
