-- /packages/intranet-idea-management/sql/postgresql/intranet-idea-management-create.sql
--
-- Copyright (c) 2011 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


-- drop table im_idea_user_map;

create sequence im_idea_user_map_seq;
create table im_idea_user_map (
	map_id			integer
				constraint im_idea_user_map_pk primary key,
	ticket_id		integer
				constraint im_idea_user_map_ticket_fk
				references im_tickets,
	user_id			integer
				constraint im_idea_user_map_user_fk
				references persons,
	last_modified		timestamptz,
	thumbs_direction	varchar(10)
				constraint im_idea_user_map_thumbs_dir_ck
				check (thumbs_direction in ('up','down')),
				-- Distribute points
	points			integer,
				-- Money for finishing the feature
	amount			numeric(12,2)
);

create unique index im_idea_user_map_ticket_user_un on im_idea_user_map(ticket_id, user_id);


alter table im_tickets add ticket_thumbs_up_count integer;


-----------------------------------------------------------
-- Permissions & Privileges
-----------------------------------------------------------

select acs_privilege__create_privilege('view_ideas_all','View all Ideas','');
select acs_privilege__add_child('admin', 'view_ideas_all');

select acs_privilege__create_privilege('add_ideas','Add new Ideas','');
select acs_privilege__add_child('admin', 'add_ideas');

select acs_privilege__create_privilege('edit_idea_status','Add new Ideas','');
select acs_privilege__add_child('admin', 'edit_idea_status');

-- Default permissions
select im_priv_create('add_ideas', 'Employees');
select im_priv_create('add_ideas', 'Customers');
select im_priv_create('add_ideas', 'Freelancers');

select im_priv_create('view_ideas_all', 'Senior Managers');
select im_priv_create('view_ideas_all', 'Project Managers');
select im_priv_create('view_ideas_all', 'Employees');

select im_priv_create('edit_idea_status', 'Senior Managers');



-----------------------------------------------------------
-- New "Idea" Ticket Type
--
-- 74000-74999  Intranet Idea Management (1000)
-- 74000-74099  Intranet Idea Type (100)
-- 74100-74199  Intranet Idea Status (100)

SELECT im_category_new (30180, 'Idea', 'Intranet Ticket Type');


----------------------------------------------------------
-- Define workflow for ideas
----------------------------------------------------------

-- by default use "idea_generic_wf"
update im_categories set aux_string1 = 'idea_generic_wf'
where	category_id = 30180;



-----------------------------------------------------------
-- Idea Plugin
--

SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_user
	null,				-- creation_ip
	null,				-- context_id
	'Ideas',			-- plugin_name - shown in menu
	'intranet-idea-management',	-- package_name
	'left',				-- location
	'/intranet-idea-management/new',	-- page_url
	null,				-- view_name
	10,				-- sort_order
	'im_idea_component -object_id $idea_id',	-- component_tcl
	'lang::message::lookup "" "intranet-idea-management.Ideas" "Ideas"'
);

SELECT acs_permission__grant_permission(
	(select plugin_id from im_component_plugins where plugin_name = 'Ideas' and package_name = 'intranet-idea-management'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


-----------------------------------------------------------
-- Idea Submenu
--

create or replace function inline_0 ()
returns integer as '
declare
	-- Menu IDs
	v_menu			integer;
	v_main_menu		integer;

	-- Groups
	v_employees		integer;
	v_accounting		integer;
	v_senman		integer;
	v_customers		integer;
	v_freelancers		integer;
	v_proman		integer;
	v_reg_users		integer;
BEGIN
	-- Get some group IDs
	select group_id into v_senman from groups where group_name = ''Senior Managers'';
	select group_id into v_proman from groups where group_name = ''Project Managers'';
	select group_id into v_accounting from groups where group_name = ''Accounting'';
	select group_id into v_employees from groups where group_name = ''Employees'';
	select group_id into v_customers from groups where group_name = ''Customers'';
	select group_id into v_freelancers from groups where group_name = ''Freelancers'';
	select group_id into v_reg_users from groups where group_name = ''Registered Users'';

	-- Determine the main menu. "Label" is used to
	-- identify menus.
	select menu_id into v_main_menu
	from im_menus where label=''main'';

	-- Create the menu.
	v_menu := im_menu__new (
		null,				-- p_menu_id
		''im_menu'',			-- object_type
		now(),				-- creation_date
		null,				-- creation_user
		null,				-- creation_ip
		null,				-- context_id
		''intranet-idea-management'',	-- package_name
		''ideas'',			-- label
		''Ideas'',			-- name
		''/intranet-idea-management/'',	-- url
		85,				-- sort_order
		v_main_menu,			-- parent_menu_id
		null				-- p_visible_tcl
	);

	-- Grant read permissions to most of the system
	PERFORM acs_permission__grant_permission(v_menu, v_employees, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_customers, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_freelancers, ''read'');
	PERFORM acs_permission__grant_permission(v_menu, v_reg_users, ''read'');

	return 0;
end;' language 'plpgsql';
select inline_0 ();
drop function inline_0 ();


-----------------------------------------------------------
-- "Top" Tab for idea submenu
--

SELECT im_menu__new (
	null,					-- p_menu_id
	'im_menu',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'intranet-idea-management',		-- package_name
	'ideas_top',				-- label
	'Top',					-- name
	'/intranet-idea-management/index?perspective=Top',	-- url
	10,					-- sort_order
	(select menu_id from im_menus where label = 'ideas'),
	null					-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'ideas_top'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);



SELECT im_menu__new (
	null,					-- p_menu_id
	'im_menu',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'intranet-idea-management',		-- package_name
	'ideas_hot',				-- label
	'Hot',					-- name
	'/intranet-idea-management/index?perspective=Hot',	-- url
	30,					-- sort_order
	(select menu_id from im_menus where label = 'ideas'),
	null					-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'ideas_hot'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


-- Status "New"
SELECT im_menu__new (
	null,					-- p_menu_id
	'im_menu',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'intranet-idea-management',		-- package_name
	'ideas_new',				-- label
	'New',					-- name
	'/intranet-idea-management/index?perspective=New',	-- url
	40,					-- sort_order
	(select menu_id from im_menus where label = 'ideas'),
	null					-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'ideas_new'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


-- Status "Accepted"
SELECT im_menu__new (
	null,					-- p_menu_id
	'im_menu',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'intranet-idea-management',		-- package_name
	'ideas_accepted',				-- label
	'Accepted',					-- name
	'/intranet-idea-management/index?perspective=Accepted',	-- url
	80,					-- sort_order
	(select menu_id from im_menus where label = 'ideas'),
	null					-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'ideas_accepted'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);


-- Status "Done"
SELECT im_menu__new (
	null,					-- p_menu_id
	'im_menu',				-- object_type
	now(),					-- creation_date
	null,					-- creation_user
	null,					-- creation_ip
	null,					-- context_id
	'intranet-idea-management',		-- package_name
	'ideas_done',				-- label
	'Done',					-- name
	'/intranet-idea-management/index?perspective=Done',	-- url
	90,					-- sort_order
	(select menu_id from im_menus where label = 'ideas'),
	null					-- p_visible_tcl
);

SELECT acs_permission__grant_permission(
	(select menu_id from im_menus where label = 'ideas_done'), 
	(select group_id from groups where group_name = 'Employees'),
	'read'
);



-----------------------------------------------------------
-- IdeaListPage Main View
-----------------------------------------------------------

-- 950-959              intranet-idea-management


delete from im_view_columns where view_id = 950;
delete from im_views where view_id = 950;
insert into im_views (view_id, view_name, visible_for, view_type_id)
values (950, 'idea_list', '', 1400);


insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(95000,950,00, 'Prio','"$idea_prio"');

insert into im_view_columns (column_id, view_id, sort_order, column_name, column_render_tcl) values
(95010,950,10, 'Nr','"<a href=/intranet-idea-management/new?form_mode=display&idea_id=$idea_id>$project_nr</a>\
<a href=/intranet-idea-management/new?form_mode=edit&idea_id=$idea_id>[im_gif wrench]</a>"');



-----------------------------------------------------------
-- DynField Widgets
--

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'idea_priority', 'Idea Priority', 'Idea Priority',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Idea Priority"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'telephony_request_type', 'Telephony Request Type', 'Telephony Request Type',
	10007, 'integer', 'im_category_tree', 'integer',
	'{custom {category_type "Intranet Idea Telephony Request Type"}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'customer_contact', 'Customer Contact', 'Customer Contacts',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {select u.user_id, im_name_from_user_id(u.user_id) from registered_users u, group_distinct_member_map gm where u.user_id = gm.member_id and gm.group_id = 461 order by lower(im_name_from_user_id(u.user_id)) }}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'idea_assignees', 'Idea Assignees', 'Idea Assignees',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {
		select u.user_id, im_name_from_user_id(u.user_id) from registered_users u, 
		group_distinct_member_map gm where u.user_id = gm.member_id and gm.group_id in (
			select group_id from groups where group_name = ''Helpdesk''
		) order by lower(im_name_from_user_id(u.user_id)) 
	}}}'
);

SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'idea_po_components', 'Idea &#93;po&#91; Components', 'Idea &#93;po&#91; Components',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {
select	ci.conf_item_id,
	ci.conf_item_name
from	im_conf_items ci
where	ci.conf_item_parent_id in (
		select	conf_item_id
		from	im_conf_items
		where	conf_item_parent_id is null and
			conf_item_nr = ''po''
	)
order by
	ci.conf_item_nr
}}}');


SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'service_level_agreements', 'Service Level Agreements', 'Service Level Agreements',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {
		select	
			p.project_id,
			p.project_name
		from 
			im_projects p
		where 
			p.project_type_id = 2502 and
			p.project_status_id in (select * from im_sub_categories(76))
		order by 
			lower(project_name) 
	}}}'
);





-----------------------------------------------------------
-- Hard Coded DynFields
--
SELECT im_dynfield_attribute_new (
	'im_ticket', 'xxx_name', 'Name', 'textbox_medium', 'string', 'f', 0, 't', 'im_projects'
);
SELECT im_dynfield_attribute_new (
	'im_idea', 'parent_id', 'Service Level Agreement', 'service_level_agreements', 
	'integer', 'f', 10, 't', 'im_projects'
);
SELECT im_dynfield_attribute_new (
	'im_idea', 'idea_status_id', 'Status', 'idea_status', 'integer', 'f', 20, 't', 'im_ideas'
);
SELECT im_dynfield_attribute_new (
	'im_idea', 'idea_type_id', 'Type', 'idea_type', 'integer', 'f', 30, 't', 'im_ideas'
);



-----------------------------------------------------------
-- Other fields
--

SELECT im_dynfield_attribute_new ('im_idea', 'idea_prio_id', 'Priority', 'idea_priority', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_assignee_id', 'Assignee', 'idea_assignees', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_note', 'Note', 'textarea_small', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_component_id', 'Software Component', 'idea_po_components', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_conf_item_id', 'Hardware Component', 'conf_items_servers', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_description', 'Description', 'textarea_small', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_customer_deadline', 'Desired Customer End Date', 'date', 'date', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_quoted_days', 'Quoted Days', 'numeric', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_quote_comment', 'Quote Comment', 'textarea_small_nospell', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_telephony_request_type_id', 'Telephony Request Type', 'telephony_request_type', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_telephony_old_number', 'Old Number/ Location', 'textbox_medium', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_telephony_new_number', 'New Number/ Location', 'textbox_medium', 'string', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_customer_contact_id', 'Customer Contact', 'customer_contact', 'integer', 'f');
SELECT im_dynfield_attribute_new ('im_idea', 'idea_dept_id', 'Department', 'cost_centers', 'integer', 'f');



