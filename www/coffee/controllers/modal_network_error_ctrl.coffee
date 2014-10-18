gmApp.controller "ModalNetworkErrorCtrl", ($scope, apiService) ->
  $scope.retryNetwork = ->
    apiService.networkCheck().success(->
      $scope.networkErrorMessage = "Retry failed"
      $scope.modalNetworkError.hide()
    ).error (data, status) ->
      $scope.networkErrorMessage = "Retry failed"  if status is 404
