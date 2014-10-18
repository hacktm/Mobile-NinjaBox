gmApp.factory 'appManager', ($rootScope, $q, $state, dataStore, modalsRepo, apiService, bleService, checkinService) ->

  _initializedAfterAppStart = false
  _initializedAfterAuthOk = false

  _updateCurrentHost = ->
    if dataStore.hosts?.length
      for h in dataStore.hosts
        # if nearest device belongs to this host
        if h.devices.indexOf(dataStore.nearestDeviceUid) > -1
          dataStore.currentHost = h
          return




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


    # @return [$q promise]
    loadHosts: (shouldUpdateCurrentHost = true) ->
      deferred = $q.defer()
      latlng = '0,0'
      apiService.hosts(latlng, dataStore.nearestDevice).then (hosts) ->
        dataStore.hosts = angular.copy(hosts)
        _updateCurrentHost() if shouldUpdateCurrentHost
        deferred.resolve dataStore.hosts
      return deferred.promise
  }



  return returnObj
