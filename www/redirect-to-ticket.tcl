# /packages/intranet-idea-management/www/redirect-to-ticket.tcl
#
# Copyright (c) 2011 ]project-open[
# All rights reserved

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Add the current user to the desired ticket,
    IF the ticket is an idea ticket.

    @author frank.bergmann@ticket-open.com
} {
    { ticket_id:integer }
    { return_url "" }
}

# ---------------------------------------------------------------
# Default & Security
# ---------------------------------------------------------------

set current_user_id [ad_get_user_id]

set ticket_type_id [db_string ttype "
	select	ticket_type_id
	from	im_tickets
	where	ticket_id = :ticket_id
"]

if {![im_category_is_a $ticket_type_id [im_ticket_type_idea]]} {
	ad_return_complaint 1 1
	ad_script_abort
}


# ---------------------------------------------------------------
# Add the current user to the ticket,
# so that the user can see the ticket.
# ---------------------------------------------------------------

im_biz_object_add_role $current_user_id $ticket_id [im_biz_object_role_full_member]



# ---------------------------------------------------------------
# Redirect to the ticket
# ---------------------------------------------------------------

ad_returnredirect [export_vars -base "/intranet-helpdesk/new" {ticket_id return_url {form_mode display}}]

