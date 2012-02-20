# /packages/intranet-idea-management/www/index.tcl
#
# Copyright (c) 2011 ]project-open[
# All rights reserved

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    @author frank.bergmann@ticket-open.com
} {
    { order_by "Points" }
    { mine_p "all" }
    { ticket_status_id:integer "[im_ticket_status_open]" }
    { ticket_type_id:integer "[im_ticket_type_idea]" }
    { letter:trim "" }
    { start_idx:integer 0 }
    { how_many "" }
    { view_name "idea_management_list" }
    { idea_search "" }
    { perspective "" }
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

set current_user_id [ad_get_user_id]
set page_title [lang::message::lookup "" intranet-idea-management.Idea_Management "Idea Management"]
set context_bar [im_context_bar $page_title]
set page_focus "im_header_form.keywords"
set letter [string toupper $letter]
set max_description_len 200


set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
set return_url [im_url_with_query]

set view_ideas_all_p 1
set edit_ideas_all_p 1

# Security: Unprivileged users can only see ideas
set idea_ticket_type_id [im_ticket_type_idea]
if {!$view_ideas_all_p && !$user_is_admin_p} { set ticket_type_id $idea_ticket_type_id }

# Parameter passing from XoWiki includelet:
# Allow the includelet to disable the "master" on this page.
if {![info exists show_template_p]} { set show_template_p 1 }


set ticket_bulk_actions_p $user_is_admin_p

# ---------------------------------------------------------------
# Perspectives
# ---------------------------------------------------------------

set order_by_clause "thumbs_up_count DESC"

switch $perspective {
    Top { set order_by_clause "thumbs_up_count DESC" }
    Hot { set order_by_clause "thumbs_up_count_in_last_month, thumbs_up_count DESC" }
    New { set order_by_clause "creation_date DESC" }
    Accepted { set ticket_status_id [im_ticket_status_assigned] }
    Done { set ticket_status_id [im_ticket_status_closed] }
    default {
	# Nothing, show "Top" order
    }
}



# ---------------------------------------------------------------
# Main SQL
# ---------------------------------------------------------------


set ideas_sql "
	select	t.*,
		t.ticket_id as idea_id,
		p.*,
		ium.*,
		o.creation_user,
		o.creation_date,
		u.username,
		coalesce(t.ticket_thumbs_up_count, 0) as thumbs_up_count,
		(select count(*) from im_idea_user_map m where thumbs_direction='up' and last_modified > now()::date -30) as thumbs_up_count_in_last_month,
		(select count(*)-1 from im_forum_topics ft where ft.object_id = t.ticket_id) as comment_count,
		(select min(topic_id) from im_forum_topics ft2 where ft2.object_id = t.ticket_id and ft2.parent_id is null) as forum_topic_id
	from	im_tickets t
		LEFT OUTER JOIN im_idea_user_map ium ON (ium.ticket_id = t.ticket_id and ium.user_id = :current_user_id),
		im_projects p,
		acs_objects o
		LEFT OUTER JOIN users u ON (o.creation_user = u.user_id)
	where	t.ticket_id = p.project_id and
		p.project_id = o.object_id and
		t.ticket_type_id in ([join [im_sub_categories $idea_ticket_type_id] ","]) and
		t.ticket_status_id in ([join [im_sub_categories $ticket_status_id] ","])
	order by
		$order_by_clause,
		t.ticket_prio_id
"


# ---------------------------------------------------------------
# Create the main ideas multirow
# ---------------------------------------------------------------

db_multirow -extend {idea_url idea_description thumbs_down_url thumbs_up_url thumbs_undo_url dollar_url comments_url ticket_status ticket_type creator_url creator_name} ideas ideas_query $ideas_sql {

#    set idea_url [export_vars -base "/intranet-helpdesk/new" {return_url {ticket_id $idea_id} {form_mode display}}]
    set idea_url [export_vars -base "/intranet-idea-management/redirect-to-ticket" {{ticket_id $idea_id} return_url}]
    set dollar_url [export_vars -base "/intranet-idea-management/dollar-action" {return_url ticket_id}]
    set comments_url [export_vars -base "/intranet-forum/new" {return_url {parent_id $forum_topic_id}}]

    set idea_description [ns_quotehtml [string range $ticket_description 0 $max_description_len]]
    if {[string length $idea_description] >= $max_description_len} { append idea_description "... (<a href='$idea_url'>more</a>)" }

    set creator_name $username
    if {[regexp {^([a-z0-9A-Z\-_]*)@} $creator_name match username_body]} { set creator_name $username_body }
    set creator_url [export_vars -base "/intranet/users/view" {{user_id $creation_user}}]

    set ticket_status [im_category_from_id -translate_p 1 $ticket_status_id]
    set ticket_type [im_category_from_id -translate_p 1 $ticket_type_id]

    set thumbs_up_url [export_vars -base "/intranet-idea-management/thumbs-action" {return_url {ticket_id $idea_id} {direction up}}]
    set thumbs_down_url [export_vars -base "/intranet-idea-management/thumbs-action" {return_url {ticket_id $idea_id} {direction down}}]
    set thumbs_undo_url [export_vars -base "/intranet-idea-management/thumbs-action" {return_url {ticket_id $idea_id} {direction undo}}]


#    if {"SVN Import" == $project_name} { ad_return_complaint 1 "<pre>idea_id=$idea_id\ncomment_count=$comment_count</pre>" }

}


# Define a few GIFs that are used in the ADP
set comment_gif [im_gif comments]
set thumbs_up_pale_24 [im_gif "thumbs_up.pale.24"]
set thumbs_down_pale_24 [im_gif "thumbs_down.pale.24"]
set thumbs_up_pressed_24 [im_gif "thumbs_up.pressed.24"]
set thumbs_down_pressed_24 [im_gif "thumbs_down.pressed.24"]

regexp {src=\"([a-z0-9A-Z_\./]*)\"} $thumbs_up_pale_24 match thumbs_up_pale_24_gif
regexp {src=\"([a-z0-9A-Z_\./]*)\"} $thumbs_up_pressed_24 match thumbs_up_pressed_24_gif


# ---------------------------------------------------------------
# User thumbed tickets
# ---------------------------------------------------------------

set thumbed_tickets_sql "
	select	t.*,
		t.ticket_id as idea_id,
		p.*,
		ium.*
	from	im_tickets t,
		im_projects p,
		im_idea_user_map ium
	where	t.ticket_id = p.project_id and
		ium.ticket_id = t.ticket_id and 
		ium.user_id = :current_user_id and
		ium.thumbs_direction is not null and
		t.ticket_type_id in ([join [im_sub_categories $idea_ticket_type_id] ","])
	order by
		coalesce(t.ticket_thumbs_up_count,-0.5) DESC,
		t.ticket_prio_id
"


# ---------------------------------------------------------------
# Create mulirow for the user thumbed tickets
# ---------------------------------------------------------------

set max_thumbs_count 10
set thumb_count 0
db_multirow -extend {idea_url thumbs_undo_url ticket_status} thumbed_tickets thumbed_tickets_query $thumbed_tickets_sql {

    set idea_url [export_vars -base "/intranet-helpdesk/new" {return_url ticket_id {form_mode display}}]
    set thumbs_undo_url [export_vars -base "/intranet-idea-management/thumbs-action" {return_url {ticket_id $idea_id} {direction "undo"}}]

    set ticket_status [im_category_from_id -translate_p 1 $ticket_status_id]
    incr thumb_count
}


set remaining_thumbs [expr $max_thumbs_count - $thumb_count]




# ---------------------------------------------------------------
# Count how many surveys the user has filled out
# ---------------------------------------------------------------

set survey_count [db_string survey_count "
	select	count(*)
	from	survsimp_responses sr,
		acs_objects o
	where	sr.response_id = o.object_id and
		o.creation_user = :current_user_id and
		survey_id in (438275, 438249, 305439)
"]

# ---------------------------------------------------------------
# Sub-Navbar
# ---------------------------------------------------------------

set next_page_url ""
set previous_page_url ""
set menu_select_label "ideas"

set idea_navbar_html [im_idea_navbar $letter "/intranet-idea-management/index" $next_page_url $previous_page_url [list start_idx order_by how_many view_name letter] $menu_select_label]


