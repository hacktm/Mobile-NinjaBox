gmApp.directive 'hasFocus', ($timeout) ->
  restrict: 'A'
  scope:
    focusValue: '=hasFocus'
  link: ($scope, $element, attrs) ->
    $scope.$watch 'focusValue', (currentValue, previousValue) ->
      if currentValue is true and not previousValue
        $timeout ->
          $element[0].focus()

      else if currentValue is false and previousValue
        $timeout ->
          $element[0].blur()
