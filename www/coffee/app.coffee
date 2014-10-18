gmApp = angular.module('greetme', ['ionic', 'ngStorage'])

# APP_ENV = 'development'
APP_ENV = 'staging'
#APP_ENV =  'production'

SERVER_BASE_URL = 'http://ninjabox-greetme.herokuapp.com/consumers/api/v1'

_BLE_LOG_LEVEL = 0 # 0=silent, 1=only_major_events, 2=everything

gmApp.constant('APP_CONFIG', {
  api_app_key: 'app-203dd97e-6a7e-4d98-953d-1c7b790b24c0'


  env: APP_ENV

  api_base_url: (if ionic.Platform.isWebView() then SERVER_BASE_URL else if APP_ENV == 'development' then 'http://localhost:3000/consumers/api/v1' else SERVER_BASE_URL)
  # api_base_url: SERVER_BASE_URL


  ble_use_mock_service: true


  checkin_between_requests_pause_milliseconds: 60 * 1000  # 60 seconds

  mixpanel_token: ''
})


gmApp.constant('EVENTS', {
  BLE_SCAN_CYCLE_COMPLETE: 'ble.scan.cycle-complete'
  BLE_SCAN_RESULT: 'ble.scan.result'
  NETWORK_ERROR: 'network.error'
  NETWORK_RECOVER: 'network.recover'
})



appStates = {
  splashscreen: 'splashscreen'
  welcome:      'start.welcome'
  login:        'start.email-login'
  main:         'app.hosts-nearby'
}




gmApp.config ($stateProvider, $urlRouterProvider, $httpProvider, $provide) ->

  delete $httpProvider.defaults.headers.common['X-Requested-With']



  $stateProvider

  .state 'splashscreen',
    url: '/'
    templateUrl: 'templates/splashscreen.html'



  .state 'start',
    url: '/start'
    abstract: true
    templateUrl: 'templates/start.html'
    controller: 'StartCtrl'

  .state 'start.welcome',
    url: '/welcome'
    templateUrl: 'templates/start.welcome.html'

  .state 'start.email-signup',
    url: '/start-email-signup'
    templateUrl: 'templates/start.email-signup.html'

  .state 'start.email-login',
    url: '/start-email-login'
    templateUrl: 'templates/start.email-login.html'

  .state 'start.password-reset',
    url: '/start-password-reset'
    templateUrl: 'templates/start.password-reset.html'





  .state 'app',
    url: '/app'
    abstract: true
    templateUrl: 'templates/app.html'
    controller: 'AppCtrl'
#    resolve:
#      hosts: (appManager) ->
#        return appManager.loadHosts()


  .state 'app.hosts-nearby',
    url: '/hosts/nearby'
    templateUrl: 'templates/app.list.html'
    controller: 'ListCtrl'


  .state 'app.hosts-subscribed',
    url: '/hosts/subscribed'
    templateUrl: 'templates/app.list.html'
    controller: 'ListCtrl'


  .state 'app.host-details',
    url: '/hosts/{hostId:[0-9]+}'
    templateUrl: 'templates/app.details.html'
    controller: 'DetailsCtrl'


  .state 'app.settings',
    url: '/settings'
    templateUrl: 'templates/app.settings.html'
    controller: 'SettingsCtrl'


  .state 'app.profile',
    url: '/settings/profile'
    templateUrl: 'templates/app.settings.profile.html'
    controller: 'ProfileCtrl'


  .state 'app.subscriptions',
    url: '/settings/subscriptions'
    templateUrl: 'templates/app.settings.subscriptions.html'
    controller: 'ListCtrl'


  $urlRouterProvider.otherwise('/')







############################
## MAIN ENTRY POINT
##
gmApp.run ($rootScope, $ionicPlatform, $ionicTabsConfig, $state, $ionicLoading, $timeout, appManager, accountManager, apiService, APP_CONFIG, EVENTS) ->

  $rootScope.networkRetry = {}
  $rootScope.networkRetry.count = 1

  _popupNetworkErrorVisible = false

  _popupNetworkError =
    show: ->
      if _popupNetworkErrorVisible
        $rootScope.networkRetry.count++
      else
        _popupNetworkErrorVisible = true
        $rootScope.networkRetry.count = 1
        $ionicLoading.show templateUrl: 'templates/popups/popup-network-error.html'

    hide: ->
      _popupNetworkErrorVisible = false
      $rootScope.networkRetry.count = 0
      $timeout ->
        $ionicLoading.hide()
      , 1500





  # Default disable tabs-stripped for all platforms
  $ionicTabsConfig.type = ''


  $ionicPlatform.ready ->

    if window.cordova && window.cordova.logger
      window.cordova.logger.__onDeviceReady()

    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard for form inputs)
    if window.cordova && window.cordova.plugins && window.cordova.plugins.Keyboard
      window.cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)

    if window.StatusBar
#      StatusBar.overlaysWebView(false)
      StatusBar.styleDefault()



    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
      console.log '[APP-state] changed: ' + fromState.name + '(' + angular.toJson(fromParams) + ')  -->  ' + toState.name + '(' + angular.toJson(toParams) + ')'




    $rootScope.$on EVENTS.NETWORK_ERROR, (event, status) ->
      console.log "broadcast received network.error: #{status}: " + angular.toJson(event)
      if status == 0
        _popupNetworkError.show()


    $rootScope.$on EVENTS.NETWORK_RECOVER, (event, userIsAuthenticated) ->
      console.log "broadcast received network.recover: " + angular.toJson(event)
      _popupNetworkError.hide()
      # check if we received network.error event before app was initialized and
      # user is already authenticated from a previous session
      if userIsAuthenticated
        # user authenticated: move to 'app' state unless already in there
        _enterAuthenticatedAppState() unless $state.includes('app.*')
      else
        # not authenticated: move to 'start' state
        $state.go appStates.welcome unless $state.includes('start.*')



    _enterAuthenticatedAppState = ->
      appManager.initializeAfterAuthOk()
      appManager.enterMainAppState()


    #########################

    accountManager.localLoadCurrentUser()

    appManager.preInitialize().then (networkCheckResult) ->
      console.log('Network/Auth check result: '+ networkCheckResult)
      if networkCheckResult == 'auth_ok'
        _enterAuthenticatedAppState()
      else if networkCheckResult != 'server_unreachable'
        $state.go appStates.welcome
      else
        $state.go appStates.splashscreen


