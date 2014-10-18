gmApp.directive 'gmHostDetails', ->
  restrict: 'E'
  replace: true
  transclude: true
  templateUrl: 'templates/directives/gm-host-details.html'
#  link: (scope, element, attrs, ctrl, transclude) ->
#    # http://angular-tips.com/blog/2014/03/transclusion-and-scopes/
#    transclude scope, (clone, scope) ->
#      element.append clone
