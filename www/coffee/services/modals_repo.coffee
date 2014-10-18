gmApp.factory 'modalsRepo', ($ionicModal) ->

  _initialized = false
  _modals = {}




  serviceObj = {
    initialize: ->
      #TODO: return a promise after all modals are initialized

      return if _initialized

      _initialized = true
  }


  return serviceObj
