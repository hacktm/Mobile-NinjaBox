gmApp.controller 'ProfileCtrl', ($scope, accountManager, dataStore) ->

  console.log('ProfileCtrl started')

  $scope.userData = angular.copy(dataStore.currentUser)


  $scope.sharePhoto = ->
    accountManager.doPhotoUpload().then (user) ->
      $scope.userData = angular.copy(dataStore.currentUser)

  $scope.updateProfile = ->
    accountManager.doUpdateProfile $scope.userData

