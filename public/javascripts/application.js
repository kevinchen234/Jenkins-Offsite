// This file is automatically included by javascript_include_tag :defaults

/**
 * Setup the lightbox for doing ldap searches
 */
function setup_lightbox() {
  $("a.lightbox").fancybox({
    'zoomSpeedIn': 0,
    'zoomSpeedOut': 0,
    'overlayShow': true,
    'frameWidth': 900,
    'frameHeight': 500,
    'hideOnContentClick': false,
    'padding': 10,
    'callbackOnShow' : function() { $("input#ldap_search_search_value").focus(); }
  });
}

/**
 * Toggles display of the field off_site_request#arachne_or_socrates as this
 * field is only required if off_site_request#hostname_in_use == true
 */
function observe_hostname_in_use() {
  $("input#off_site_request_hostname_in_use_true").click( function () {
    $("#off_site_request_arachne_or_socrates_input").slideDown('fast');
  });

  $("input#off_site_request_hostname_in_use_false").click( function () {
    $("#off_site_request_arachne_or_socrates_input").slideUp('fast');
    $("input#off_site_request_arachne_or_socrates_true").attr("checked", "");
    $("input#off_site_request_arachne_or_socrates_false").attr("checked", "");
  });

  if ($("input#off_site_request_hostname_in_use_true").attr("checked") === false) {
    $("#off_site_request_arachne_or_socrates_input").hide();
  }
}

/**
 * Toggles display of the field off_site_request#(name_of_group, relationship_of_group) as these
 * fields are only required if off_site_request#for_department_sponsor == false
 */
function observe_for_department_sponsor() {
  $("input#off_site_request_for_department_sponsor_false").click( function () {
    $("#off_site_request_name_of_group_input").slideDown('fast');
    $("#off_site_request_relationship_of_group_input").slideDown('fast');
  });

  $("input#off_site_request_for_department_sponsor_true").click( function () {
    $("#off_site_request_name_of_group_input").slideUp('fast');
    $("#off_site_request_relationship_of_group_input").slideUp('fast');
    $("input#off_site_request_name_of_group").attr("value", "");
    $("input#off_site_request_relationship_of_group").attr("value", "");
  });

  if ($("input#off_site_request_for_department_sponsor_false").attr("checked") === false) {
    $("#off_site_request_name_of_group_input").hide();
    $("#off_site_request_relationship_of_group_input").hide();
  }
}

/**
 * Toggles display of the field off_site_request#campus_buyer as this field
 * is only required if off_site_request#sla_reviewed_by == 1 (CAMPUS_BUYER)
 */

// function observe_sla_reviewed_by() {
//   $("input#off_site_request_sla_reviewed_by_0").click( function () {
//     $("#off_site_request_campus_buyer_input").slideDown('fast');
//   });

//   $("input#off_site_request_sla_reviewed_by_1").click( function () {
//     $("#off_site_request_campus_buyer_input").slideUp('fast');
//     $("select#off_site_request_campus_buyer_id option").each(function() {
//       jQuery(this).removeAttr("selected");
//     });
//   });

//   if ($("input#off_site_request_sla_reviewed_by_0").attr("checked") === false) {
//     $("#off_site_request_campus_buyer_input").hide();
//   }
// }

/**
 * When doing ldap lookups for users, campus officials or submitters, this method
 * handles auto population of the main form after a specific record is selected
 * from the ldap search.
 */
function observe_and_update_user(search_for) {
  $("table#user_search_results tbody tr a").each(function() {
    jQuery(this).click(function() {
      var queryString = jQuery(this).attr("href").split("?")[1];
      var attrs = queryString.split("&");

      var attrMap = {};
      for (var i in attrs) {
        var tokens = attrs[i].split("=");
        attrMap[tokens[0]] = tokens[1];
      }

      if (search_for === "campus_official" || search_for === "submitter") {
        if (attrMap["email"] == "") {
          $("#fancy_ajax #ldap_search_content").css("display", "none");
          $("#fancy_ajax div#ldap_select_error").css("display", "block");
        } else {
          var ldap_uid_input = "#off_site_request_" + search_for + "_ldap_uid";
          var full_name_input = "#off_site_request_" + search_for + "_full_name";
          $(ldap_uid_input).attr("value", attrMap["ldap_uid"]);
          $(full_name_input).attr("value", attrMap["full_name"]);
          $.fn.fancybox.close();
        }
      } else {
        for (var attr in attrMap) {
          if (attr != "fullname") {
            $("#user_" + attr).attr("value", attrMap[attr]);
          }
        }
        $.fn.fancybox.close();
      }

      return false;
    });
  });
}

function observe_and_update_campus_official() {
  observe_and_update_user("campus_official");
}

function observe_and_update_submitter() {
  observe_and_update_user("submitter");
}

function toggle_ldap_select_error() {
  $("#fancy_ajax div#ldap_select_error a#search_again").each(function() {
    jQuery(this).click(function() {
      $("#fancy_ajax #ldap_search_content").toggle();
      $("#fancy_ajax div#ldap_select_error").toggle();
      return false;
    });
  });
}

jQuery(function($) {
    var loading_img = function() { $('div#loading_img').css('display', 'inline') };
    var complete_img = function() { $('div#loading_img').css('display', 'none') };

    $("#new_ldap_search")
        .bind("ajax:beforeSend", loading_img())
        .bind("ajax:complete", complete_img());
});