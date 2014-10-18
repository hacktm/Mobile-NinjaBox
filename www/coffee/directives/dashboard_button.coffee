gmApp.directive 'dashboardButton', ($state, $timeout) ->
  restrict: 'E'
  replace: true
  scope:
    icon: '@icon'
    label: '@label'
  template: '''
            <a class="item item-icon-left item-icon-right dashboard-button-item">
                <i class="icon left-icon {{ icon }}"></i>
                <span class="button-text">{{ label }}</span>
                <i class="icon right-arrow ion-ios7-arrow-right"></i>
            </a>
            '''

