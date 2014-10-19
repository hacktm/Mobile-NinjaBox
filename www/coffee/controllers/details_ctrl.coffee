gmApp.controller 'DetailsCtrl', ($scope, $stateParams, $q, $timeout, $ionicPopup, $ionicLoading, dataStore, apiService, bleService, modalsRepo, EVENTS) ->

  console.log('DetailsCtrl started')

  self = @

  $scope.DEVICE_STATE_IDLE    = 0
  $scope.DEVICE_STATE_WAITING = 1
  $scope.DEVICE_STATE_DONE    = 2

  $scope.host = dataStore.getHostById($stateParams.hostId)
  $scope.device = dataStore.nearestDevice
  $scope.loading = {}
  $scope.rating = dataStore.ratings[$scope.host.business_id] || 0 # 1-based index, 0 = not rated 
  $scope.isRated = !!$scope.rating

  $scope.range = (n) -> new Array(n)

  $scope.rate = (stars) ->
    unless $scope.isRated or stars < 1 or stars > 5
      $scope.rating = stars

  $scope.lockRating = ->
    $scope.isRated = true
    dataStore.ratings[$scope.host.business_id] = $scope.rating


  $scope.tap_optIn = () ->
    $ionicLoading.show({ content: '<i class="icon ion-loading-c"></i>' })
    apiService.hostSubscribe($stateParams.hostId)
    .then (host) ->
      angular.extend($scope.host, host)
    .catch (reason) ->
      $ionicLoading.hide()
      $ionicPopup.alert
        title: "Error"
        template: angular.toJson(reason).substr(0, 100)
    .finally () ->
      $ionicLoading.hide()



  $scope.$on EVENTS.BLE_SCAN_RESULT, (event, device) ->
    $scope.device = dataStore.nearestDevice = device

