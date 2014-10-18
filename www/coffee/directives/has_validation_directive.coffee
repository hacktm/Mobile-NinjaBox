gmApp.directive 'hasValidation', ($timeout) ->
  restrict: 'A'
  scope:
    validationResult: '=hasValidation'
  link: ($scope, $element, attrs) ->
    $scope.$watch 'validationResult', (currentValue, previousValue) ->
#      if currentValue is true and not previousValue
#        $timeout ->
#          $element[0].focus()
#      else if currentValue is false and previousValue
#        $timeout ->
#          $element[0].blur()
