# /packages/intranet-idea-management/www/dollar-action.tcl
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
    ticket_id:integer
    return_url
}

set page_title [lang::message::lookup "" intranet-idea-management.Participate_in_development_costs "Participate in Development Costs"]
set current_user_id [ad_maybe_redirect_for_registration]
set context_bar [im_context_bar $page_title]
