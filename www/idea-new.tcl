# /packages/intranet-idea-management/www/idea-new.tcl
#
# Copyright (C) 2011 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Perform actions on idea tickets
    @param return_url the url to return to
    @author frank.bergmann@project-open.com
} {
    idea_title
    idea_description
    return_url
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

set current_user_id [ad_maybe_redirect_for_registration]
set max_thumbs_count 10

set thumb_count [db_string thumb_count "
	select	count(*)
	from	im_idea_user_map ium
	where	user_id = :current_user_id and
		thumbs_direction = 'up'
"]

if {$thumb_count >= $max_thumbs_count} { 
	ad_return_complaint 1 "<b>Your maximum of $max_thumbs_count votes have already been distributed</b>:<br>
	You can elimenate votes by clicking on the selected thumbs.
	"
	ad_script_abort
}

set tickets_last_week [db_string exists "
	select	count(*)
	from	im_tickets t,
		acs_objects o
	where	t.ticket_id = o.object_id and
		o.creation_user = :current_user_id and
		o.creation_date > now()::date - 7
"]

# Employees and partners are privileged
set privileged_p 0
if {[im_profile::member_p -profile_id [im_employee_group_id] -user_id $current_user_id]} { set privileged_p 1 }
if {[im_profile::member_p -profile_id 2317 -user_id $current_user_id]} { set privileged_p 1 }

if {!$privileged_p && $tickets_last_week > 5} { 
	ad_return_complaint 1 "<b>Your maximum of 5 new ideas per week has been exceeded</b>:"
	ad_script_abort
}


# ---------------------------------------------------------------
# Create the ticket
# ---------------------------------------------------------------

set ticket_sla_id [im_ticket::internal_sla_id]
set ticket_nr [im_ticket::next_ticket_nr]
set ticket_type_id [im_ticket_type_idea]
set ticket_status_id [im_ticket_status_open]

set ticket_id [im_ticket::new \
		   -ticket_sla_id $ticket_sla_id \
		   -ticket_name $idea_title \
		   -ticket_nr $ticket_nr \
		   -ticket_customer_contact_id $current_user_id \
		   -ticket_type_id $ticket_type_id \
		   -ticket_status_id $ticket_status_id \
		   -ticket_note $idea_description \
    ]

db_dml update_ticket "
	update im_tickets set
		ticket_description = :idea_description
	where ticket_id = :ticket_id
"

notification::new \
    -type_id [notification::type::get_type_id -short_name ticket_notif] \
    -object_id $ticket_id \
    -response_id "" \
    -notif_subject $idea_title \
    -notif_text $idea_description

# Write Audit Trail
im_project_audit -project_id $ticket_id -action create


ad_returnredirect $return_url
