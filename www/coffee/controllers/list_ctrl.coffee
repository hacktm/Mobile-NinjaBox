gmApp.controller 'ListCtrl', ($scope, $state, $q, $timeout, $ionicPopup, appManager, apiService, dataStore, bleService, EVENTS) ->

  console.log('ListCtrl started')

  $scope.myPlaces = $state.is('app.hosts-subscribed') or $state.is('app.subscriptions')
  $scope.viewTitle = if $scope.myPlaces then 'My' else 'Nearby'
  $scope.hostsList = null



  _loadHosts = ->
    latlng = '0,0'
    apiService.hosts(latlng, dataStore.nearestDevice).then (hosts) ->
      dataStore.hosts = angular.copy(hosts)
      # determine if in-store on the 1st host in list
      if dataStore.hosts?.length
        if dataStore.hosts[0].devices.indexOf(dataStore.nearestDeviceUid) > -1
          dataStore.currentHost = dataStore.hosts[0]
        else
          dataStore.currentHost = null
        $scope.currentHost = dataStore.currentHost
        if $scope.myPlaces
          $scope.hostsList = dataStore.hosts.filter (host) -> host.subscribed == true
        else
          $scope.hostsList = angular.copy(dataStore.hosts)


  $scope.tapRefresh = ->
    _loadHosts()

  
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



  $scope.$on EVENTS.BLE_SCAN_RESULT, (event) ->
    if (dataStore.nearestDeviceUid != dataStore.previousDeviceUid)
      _loadHosts()



  _loadHosts()


