gmApp.factory 'appManager', ($rootScope, $q, $state, dataStore, modalsRepo, apiService, bleService, checkinService, EVENTS) ->

  _initializedAfterAppStart = false
  _initializedAfterAuthOk = false





  ############################################################################################################

  returnObj = {

    # @return [$q promise]
    preInitialize: ->
      console.log('appManager.preInitialize()')
      deferred = $q.defer()

      modalsRepo.initialize()

      apiService.networkCheck()
      .then (authStatus) ->
        deferred.resolve(authStatus)
      .catch (reason) ->
        deferred.reject('server_unreachable')
      .finally ->
        apiService.startPeriodicNetworkCheck()
      return deferred.promise


    initializeAfterAuthOk: ->
      bleService.initialize()
      checkinService.initialize()


    enterMainAppState: ->
      listener = $rootScope.$on EVENTS.BLE_SCAN_CYCLE_COMPLETE, ->
        listener()
        $state.go appStates.main



    # @return [$q promise]
    loadHosts: ->
      return deferred.promise
  }



  return returnObj
