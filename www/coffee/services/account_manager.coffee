gmApp.factory 'accountManager', ($rootScope, $localStorage, $q, $state, dataStore, apiService, appManager) ->

  _updateCurrentUser = (userData) ->
    angular.extend dataStore.currentUser, humps.camelizeKeys(userData)
    $localStorage['currentUser'] = dataStore.currentUser
    return dataStore.currentUser




  ########################################################################
  serviceObj = {

    localLoadCurrentUser: ->
      _updateCurrentUser($localStorage['currentUser'])
      apiService.setUserToken(dataStore.currentUser.userToken) if dataStore.currentUser.userToken?
      return dataStore.currentUser







    doSignup: (email, greetingName) ->
     deferred = $q.defer()
     email = gmUtils.email(email)
     apiService.authSignup(email, greetingName)
     .then (data) ->
       if data.new_password is true
         deferred.resolve { password: true }
       else if gmUtils.objType(data.new_password) == 'string' && data.new_password.length > 3
         deferred.resolve { password: data.new_password }
       else
         deferred.resolve { password: false }
     .catch (reason) ->
       deferred.reject(reason)
     deferred.promise





    doLogin: (email, password) ->
      deferred = $q.defer()
      apiService.authLogin(email, password)
      .then (userData) ->
        currentUser = _updateCurrentUser(userData)
        apiService.setUserToken(currentUser.userToken)
        appManager.initializeAfterAuthOk()
        deferred.resolve(currentUser)
      .catch (reason) ->
        deferred.reject(reason)
      deferred.promise




    doResetPassword: (email) ->
      deferred = $q.defer()
      apiService.authResetPassword(email)
      .then (data) ->
        deferred.resolve(data)
      .catch (reason) ->
        deferred.reject(reason)
      deferred.promise




    doPhotoUpload: ->
      deferred = $q.defer()
      
      pictureOptions =
        quality: 70
        destinationType: Camera.DestinationType.FILE_URI
        encodingType: Camera.EncodingType.JPEG
        cameraDirection: Camera.Direction.FRONT
        targetWidth: 200
        targetHeight: 200
      
      actionsheetOptions = 
        buttonLabels: ['Take Photo', 'Choose From Library']
        addCancelButtonWithLabel: 'Cancel'
        androidEnableCancelButton : true
        winphoneEnableCancelButton : true

      pictureSuccess = (imageURI) ->
        console.log '[CORDOVA] camera.getPicture() success: ' + imageURI
        apiService.photoUpload(imageURI)
          .then (data) ->
            currentUser = _updateCurrentUser(data)
            deferred.resolve currentUser

      pictureFail = (message) -> 
        # We typically get here because the use canceled the photo operation
        console.error '[CORDOVA] camera.getPicture() fail: ' + message
        deferred.reject message

      actionsheetCallback = (buttonIndex) ->
        # like other Cordova plugins (prompt, confirm) the buttonIndex is 1-based (first button is index 1)
        switch buttonIndex
          # 'Take Photo'
          when 1 then pictureOptions.sourceType = Camera.PictureSourceType.CAMERA
          # 'Choose From Library'
          when 2 then pictureOptions.sourceType = Camera.PictureSourceType.PHOTOLIBRARY
        navigator.camera.getPicture(pictureSuccess, pictureFail, pictureOptions)

      window.plugins.actionsheet.show(actionsheetOptions, actionsheetCallback)

      deferred.promise


    ######
    #TODO: update methods below


    doUpdateProfile: (userData) ->
      deferred = $q.defer()
      apiService.updateProfile humps.decamelizeKeys(userData)
      .then (data) ->
        _updateCurrentUser(data)
        deferred.resolve(data)
      .catch (reason) ->
        deferred.reject(reason)
      deferred.promise


    remoteUpdateCurrentUser: (userData) ->
      deferred = $q.defer()
      if _data.currentUser.consumerId
        _remoteUpdateUser(_data.currentUser.consumerId, userData)
        .then (data) ->
          _updateCurrentUser(data)
          deferred.resolve _data.currentUser
        .catch (reason) ->
          deferred.reject(reason)
      else
        deferred.reject
          status: 400
          message: 'User not authenticated.'
          code: 'auth_error'
      deferred.promise

  }


  return serviceObj
