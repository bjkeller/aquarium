
(function() {

  var w;
  try {
    w = angular.module('workflow_editor'); 
  } catch (e) {
    w = angular.module('workflow_editor', []); 
  }

  var containers;
  $.ajax({
    url: '/containers.json'
  }).done(function(data) {
    containers = data;
  });

  var sample_types;
  $.ajax({
    url: '/sample_types.json'
  }).done(function(data) {
    sample_types = data;
  });  

  w.controller('ispecFormsCtrl', function ($scope,$http) {

    var that = this;
    this.ispec = { rows: 0, columns: 0 };

    $scope.init = function(ispec) {
      $.extend(that.ispec,ispec);
      angular.element().scope().$apply();      
      console.log(that.ispec);
    } 

  });

  w.directive("ispec", function() {
    return {

      restrict: 'A',

      scope: { ispec: "=" },

      link: function($scope,element,attrs) {

        // Dimensions //////////////////////////////////////////////////////////////////////

        if ( !$scope.ispec.rows ) {
          $scope.ispec.rows = 1;
        }

        if ( !$scope.ispec.columns ) {
          $scope.ispec.columns = 1;
        }        

        element.find("#scalar").attr('checked',!$scope.ispec.matrix);        
        element.find("#matrix").attr('checked', $scope.ispec.matrix);

        if ( angular.element("#scalar").attr('checked') ) {
          element.find("#dimensions").css('display', 'none');
        }

        $scope.scalar = function() {
          element.find("#dimensions").css('display', 'none');
          $scope.ispec.matrix = false;          
        };

        $scope.matrix = function() {
          element.find("#dimensions").css('display', 'block');
          $scope.ispec.matrix = true;
        }

        // Parts ///////////////////////////////////////////////////////////////////////////

        $scope.item = function() {
          element.find("#container_type").attr('disabled', false);
          $scope.ispec.is_part = false;          
        };

        $scope.part = function() {
          element.find("#container_type").attr('disabled', true);          
          element.find("#container_type").val('collection');
          $scope.ispec.is_part = true;
        }

        // Containers //////////////////////////////////////////////////////////////////////

        element.find("#container").autocomplete({
          source: containers
        });

        element.find("#sample_type").autocomplete({
          source: sample_types
        });

        $scope.sample_type = "";
        $scope.container = "";
        $scope.sample = "";

        $scope.sample_type_change = function() {
          console.log("sample type = " + element.find("#sample_type").val());
        }

        $scope.container_change = function() {
          console.log("container = " + element.find("#container").val());
        }

        $scope.sample_change = function() {
          console.log("sample = " + element.find("#sample").val());
        }                

      },

      templateUrl: "/workflow_editor/ispec.html" // this file is in ./public/
    };                                           // since putting it views confuses rails

  });  

})();

