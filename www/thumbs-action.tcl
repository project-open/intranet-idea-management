# /packages/intranet-idea-management/www/thumbs-action.tcl
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
    ticket_id:integer,multiple,optional
    direction
    return_url
}

set current_user_id [ad_maybe_redirect_for_registration]
set max_thumbs_count 10
if {"undo" == $direction} { set direction "" }

set thumb_count [db_string thumb_count "
	select	count(*)
	from	im_tickets t,
		im_idea_user_map ium
	where	ium.ticket_id = t.ticket_id and
		ium.user_id = :current_user_id and
		ium.thumbs_direction = 'up' and
		t.ticket_status_id not in ([join [im_sub_categories [im_ticket_status_closed]] ","])
"]

if {$thumb_count >= $max_thumbs_count && "" != $direction} {
	ad_return_complaint 1 "<b>Your maximum of $max_thumbs_count votes have already been distributed</b>:<br>
	You can elimenate votes by clicking on the selected thumbs.
	"
}

set exists_p [db_string exists "
	select	count(*)
	from	im_idea_user_map
	where	ticket_id = :ticket_id and
		user_id = :current_user_id
"]


if {$exists_p} {

    db_dml update "
	update	im_idea_user_map set
		thumbs_direction = :direction,
		last_modified = now()
	where	ticket_id = :ticket_id and
		user_id = :current_user_id
    "

} else {

    db_dml insert "
	insert into im_idea_user_map (
		map_id,
		ticket_id,
		user_id,
		last_modified,
		thumbs_direction
	) values (
		nextval('im_idea_user_map_seq'),
		:ticket_id,
		:current_user_id,
		now(),
		:direction
	)
    "
}


db_dml update_ticket "
	update im_tickets
	set ticket_thumbs_up_count = (
		select	count(*)
		from	im_idea_user_map
		where	ticket_id = :ticket_id and thumbs_direction = 'up'
	) - (
		select	count(*)
		from	im_idea_user_map
		where	ticket_id = :ticket_id and thumbs_direction = 'down'
	)
	where ticket_id = :ticket_id
"

ad_returnredirect $return_url
