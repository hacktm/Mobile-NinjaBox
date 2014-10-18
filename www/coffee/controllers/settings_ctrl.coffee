gmApp.controller 'SettingsCtrl', ($scope, $state, $localStorage) ->

  console.log 'SettingsCtrl started'

  $scope.logout = ->
    delete $localStorage.currentUser
    $state.go appStates.welcome