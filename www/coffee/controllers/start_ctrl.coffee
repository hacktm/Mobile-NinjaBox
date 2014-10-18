gmApp.controller 'StartCtrl', ($scope, $ionicPopup, $ionicLoading, $state, $ionicViewService, $q, appManager, accountManager) ->

  $scope.startData = {}
  $scope.focus = {}


  _loadingPopup =
    show: (content) ->
      $ionicLoading.show({ content: (content || '<i class="icon ion-loading-c"></i>') })
    hide: ->
      $ionicLoading.hide()



  _showAlertPopup = (title, content, focusInput) ->
    _loadingPopup.hide()
    deferred = $q.defer()
    if focusInput
      $scope.focus[focusInput] = false

    $ionicPopup.alert
      title: title,
      content: content
    .then ->
      if(focusInput)
        $scope.focus[focusInput] = true
      deferred.resolve()
    return deferred.promise





#
  $scope.signUp = ->
    console.log 'Signup data: ' + angular.toJson($scope.startData)
    if gmUtils.isValidText($scope.startData.greetingName, /.{2,12}/g)
      greetingName = $scope.startData.greetingName
      if gmUtils.isValidEmail($scope.startData.email)
        email = gmUtils.email($scope.startData.email)
        _loadingPopup.show()
        accountManager.doSignup(email, greetingName).then (result) ->
          if gmUtils.objType(result.password) == 'string' && result.password.length > 3
            accountManager.doLogin(email, result.password).then (authResult) ->
              _loadingPopup.hide()
              $ionicViewService.nextViewOptions  disableBack: true
              $state.go appStates.main
            , (authFailReason) ->
              _loadingPopup.hide()
              _showAlertPopup 'Authentication failed', 'Please enter a valid email & password.', 'userEmail'
          else
            _showAlertPopup 'Signup exists', 'An account already exists for the email: ' + email, 'userEmail'

        , (failReason) ->
          _showAlertPopup 'Signup failed', failReason.message + '<br><br><small>' + failReason.status + ': ' + failReason.code + '</small>', 'userEmail'
      else
        _showAlertPopup 'Invalid Email', 'Please enter a valid email address', 'userEmail'
    else
      _showAlertPopup 'Invalid Name', 'Please enter what name should we use to welcome you', 'greetingName'


#
  $scope.login = ->
    console.log 'Login data: ' + angular.toJson($scope.startData)
    email = gmUtils.email($scope.startData.email)
    password = $scope.startData.password
    if gmUtils.isValidText(password, /\S{6,50}/g)
      _loadingPopup.show()
      accountManager.doLogin(email, password).then ((user) ->
        _loadingPopup.hide()
        $ionicViewService.nextViewOptions disableBack: true
        $state.go appStates.main
      ), (reason) ->
        _loadingPopup.hide()
        _showAlertPopup 'Authentication failed', 'Please enter a valid email & password.', 'userEmail'
    else
      _showAlertPopup 'Invalid password!', 'Please re-enter the password.', 'password'


#
  $scope.resetPassword = ->
    console.log 'ResetPassword Data: ' + angular.toJson($scope.startData)
    if $scope.startData.email && gmUtils.isValidEmail($scope.startData.email)
      email = gmUtils.email($scope.startData.email)
#
      $ionicPopup.confirm
        title: 'Reset Password'
        content: 'Are you sure want reset password?'
      .then (res) ->
        if(res)
          _loadingPopup.show()
          accountManager.doResetPassword(email).then ((user) ->
            _loadingPopup.hide()
            console.log user
          ), (reason) ->
            _loadingPopup.hide()
    else
      _showAlertPopup 'Invalid email', 'Please enter a valid email address.', 'userEmail'






  $scope.submitAccountDetails = ->
    console.log 'Account details: ', $scope.data.email, $scope.data.firstName, $scope.data.lastName
    validEmail = gmUtils.isValidEmail($scope.data.email)
    validFirstName = gmUtils.isMinLengthText($scope.data.firstName, 2)
    validLastName = gmUtils.isMinLengthText($scope.data.lastName, 2)
    if validEmail and validFirstName and validLastName
      _loadingPopup.show()
      appManager.remoteUpdateCurrentUser(
        email: $scope.data.email
        first_name: $scope.data.firstName
        last_name: $scope.data.lastName
      ).then ((user) ->
        _loadingPopup.hide()
        $state.go 'dashboard'
      ), (reason) ->
        _showAlertPopup 'Update failed', 'There was an error updating your account: ' + reason.message + '<br><br>' + reason.status + ': ' + reason.code
    else
      _showAlertPopup 'Invalid data', 'Please fill-in all fields'
