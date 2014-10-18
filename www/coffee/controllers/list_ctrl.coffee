gmApp.controller 'ListCtrl', ($scope, $state, $q, $timeout, $ionicPopup, appManager, apiService, dataStore, bleService, EVENTS) ->

  console.log('ListCtrl started')

  $scope.myPlaces = $state.is('app.hosts-subscribed') or $state.is('app.subscriptions')
  $scope.viewTitle = if $scope.myPlaces then 'My' else 'Nearby'
  $scope.hostsList = null
  $scope.currentHost = dataStore.currentHost

  _refresh = -> 
    if dataStore.hosts?.length
      if $scope.myPlaces
        $scope.hostsList = dataStore.hosts.filter (host) -> host.subscribed == true 
      else
        $scope.hostsList = angular.copy(dataStore.hosts)


  $scope.tapRefresh = ->
    appManager.loadHosts().then _refresh

  
  $scope.unsubscribe = (host) ->
    confirmUnsubscribe = $ionicPopup.confirm
      title: 'Opt-out'
      scope: $scope
      template: 'Are you sure you want to opt-out?' 
    confirmUnsubscribe.then (res) -> _unsubscribe host if res


  _unsubscribe = (host) ->
    apiService.hostUnsubscribe(host.business_id).then (h) ->
      index = $scope.hostsList.indexOf(host)
      dataStoreHost = dataStore.getHostById(host.business_id)
      dataStoreIndex = dataStore.hosts.indexOf(dataStoreHost)
      $scope.hostsList.splice index, 1
      dataStore.hosts.splice dataStoreIndex, 1



  $scope.$on EVENTS.BLE_SCAN_RESULT, (event, device) ->
    # if a new device is in range or there's no device in range anymore (consumer probably moved)
    if (device? && dataStore.nearestDeviceUid != device.uid) || (device == null && dataStore.nearestDeviceUid?)
      appManager.loadHosts().then _refresh
    dataStore.nearestDevice = device


  _refresh()
