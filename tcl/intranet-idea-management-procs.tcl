# /packages/intranet-idea-management/tcl/intranet-idea-management-procs.tcl
#
# Copyright (C) 2011 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_library {
    @author frank.bergmann@project-open.com
}


# ----------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------

ad_proc -public im_idea_ticket_type_id {} { return 72000 }


# ----------------------------------------------------------------------
# Package ID
# ---------------------------------------------------------------------

ad_proc -public im_package_idea_management_id {} {
    Returns the package id of the intranet-idea-management module
} {
    return [util_memoize "im_package_idea_management_id_helper"]
}

ad_proc -private im_package_idea_management_id_helper {} {
    return [db_string im_package_core_id {
        select package_id from apm_packages
        where package_key = 'intranet-idea-management'
    } -default 0]
}


# ----------------------------------------------------------------------
# Components
# ---------------------------------------------------------------------

ad_proc -public im_idea_component {
    -object_id
} {
    Returns a HTML component to show a list of IDEA parameters with the option
    to add more parameters
} {
    set project_id $object_id
    if {![im_project_has_type $project_id "Service Level Agreement"]} { 
	ns_log Notice "im_idea_parameter_component: Project \#$project_id is not a 'Service Level Agreement'"
	return "" 
    }

    set params [list \
		    [list base_url "/intranet-idea-management/"] \
		    [list object_id $object_id] \
		    [list return_url [im_url_with_query]] \
    ]

    set result [ad_parse_template -params $params "/packages/intranet-idea-management/www/idea-parameter-list-component"]
    return [string trim $result]
}



ad_proc -public im_idea_navbar { 
    {-navbar_menu_label "ideas"}
    default_letter 
    base_url 
    next_page_url 
    prev_page_url 
    export_var_list 
    {select_label ""} 
} {
    Returns rendered HTML code for a horizontal sub-navigation
    bar for /intranet-idea-management/index.
    The lower part of the navbar also includes an Alpha bar.

    @param default_letter none marks a special behavious, hiding the alpha-bar.
    @navbar_menu_label Determines the "parent menu" for the menu tabs for 
		       search shortcuts, defaults to "projects".
} {
    # -------- Defaults -----------------------------
    set user_id [ad_get_user_id]
    set url_stub [ns_urldecode [im_url_with_query]]

    set sel "<td class=tabsel>"
    set nosel "<td class=tabnotsel>"
    set a_white "<a class=whitelink"
    set tdsp "<td>&nbsp;</td>"

    # -------- Calculate Alpha Bar with Pass-Through params -------
    set bind_vars [ns_set create]
    foreach var $export_var_list {
	upvar 1 $var value
	if { [info exists value] } {
	    ns_set put $bind_vars $var $value
	}
    }
    set alpha_bar [im_alpha_bar -prev_page_url $prev_page_url -next_page_url $next_page_url $base_url $default_letter $bind_vars]

    # Get the Subnavbar
    set parent_menu_sql "select menu_id from im_menus where label = '$navbar_menu_label'"
    set parent_menu_id [util_memoize [list db_string parent_admin_menu $parent_menu_sql -default 0]]
    
    ns_set put $bind_vars letter $default_letter
    ns_set delkey $bind_vars project_status_id

    set navbar [im_sub_navbar $parent_menu_id $bind_vars $alpha_bar "tabnotsel" $select_label]

    return $navbar
}

