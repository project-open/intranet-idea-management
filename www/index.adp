<master>
<property name="title">@page_title@</property>
<property name="context_bar">@context_bar@</property>
<property name="sub_navbar">@idea_navbar_html;noquote@</property>

<h1>@page_title@</h1>

<table>
<tr valign=top>
<td width="60%">


<form method=post action=/intranet-idea-management/idea-action>
<%= [export_form_vars {return_url} ] %>
<table>
<tr>
<td colspan=2><h2>My idea is to ...</h2></td>
</tr>
<tr>
<td><textarea name=idea_name cols=60 rows=3>...enter your idea</textarea></td>
<td><input type=submit name=submit value='#intranet-idea-management.Search#'></td>
</tr>
</table>
</form>
<br>

<form method=post action=/intranet-idea-management/idea-action>
<%= [export_form_vars {return_url} ] %>

<table class="list">

    <tr class="list-header">
	<th class="list-narrow" align=center>
		<input type=checkbox name="_dummy" onclick="acs_ListCheckAll('idea_list', this.checked)" title="Check/uncheck all rows">
	</th>
	<th class="list-narrow">&nbsp;</th>
	<th class="list-narrow">#intranet-idea-management.Name#</th>
	<th class="list-narrow">&nbsp;</th>
    </tr>

<multiple name=ideas>
    <if @ideas.rownum@ odd><tr class="list-odd" valign=top></if> 
    <else><tr class="list-even" valign=top></else>
    <!-- ------------------- Start one element ---------------------------- -->

	<td class="list-narrow">
		<input type=checkbox name=param_ids value=@ideas.ticket_id@ id='idea_list,@ideas.ticket_id@'>
	</td>

	<td>
		<div style="width: 50px; height: 35px;	border: solid 1px #ccc; -moz-border-radius: 5px; -webkit-border-radius: 5px; border-radius: 5px; text-align: center">
		<div style="color: #333; margin-bottom: -0.3em; letter-spacing: -1px; font-weight: bold; font-size: 200%">
		<if "" ne @ideas.ticket_thumbs_up_count@>
		@ideas.ticket_thumbs_up_count@
		</div>
		<if 1 eq @ideas.ticket_thumbs_up_count@>#intranet-idea-management.Thumb#</if>
		<else>#intranet-idea-management.Thumbs#</else>
		</div>
		</if>
	</td>

	<td class="list-narrow">
		<a href="@ideas.idea_url;noquote@">@ideas.project_name@</a>
		<br>
		@ideas.idea_description;noquote@
		<br>
		#intranet-idea-management.From#: <a href="@ideas.creator_url;noquote@">@ideas.creator_name@</a>
		|
		<if @ideas.comment_count@>
		@comment_gif;noquote@ @ideas.comment_count@ 
		<if @ideas.comment_count@ eq 1>#intranet-idea-management.Comment#</if>
		<else>#intranet-idea-management.Comments#</else>
		| 
		</if>
		#intranet-idea-management.Status#: @ideas.ticket_status@
		|
		#intranet-idea-management.Type#: @ideas.ticket_type@

	</td>

	<td>
		<if "up" eq @ideas.thumbs_direction@>
		<a href="@ideas.thumbs_undo_url;noquote@">@thumbs_up_pressed_24;noquote@</a><br>
		</if>
		<else>
		<a href="@ideas.thumbs_up_url;noquote@">@thumbs_up_pale_24;noquote@</a><br>
		</else>

		<if "down" eq @ideas.thumbs_direction@>
		<a href="@ideas.thumbs_undo_url;noquote@">@thumbs_down_pressed_24;noquote@</a><br>
		</if>
		<else>
		<a href="@ideas.thumbs_down_url;noquote@">@thumbs_down_pale_24;noquote@</a><br>
		</else>


	</td>

    <!-- ------------------- End of one element ---------------------------- -->
    </tr>
</multiple>
</table>



</td>
<td align=left width="40%">

	<table>
	<tr>
	<td>
	<%= [im_box_header [lang::message::lookup "" intranet-idea-management.Your_Voted_Items "Your Voted Items"]] %>
		<table class="list">
		    <tr class="list-header">
			<th class="list-narrow">&nbsp;</th>
			<th class="list-narrow">&nbsp;</th>
		    </tr>
		<multiple name=thumbed_tickets>
		    <if @thumbed_tickets.rownum@ odd><tr class="list-odd" valign=top></if> 
		    <else><tr class="list-even" valign=top></else>

			<td class="list-narrow">
				<if "up" eq @thumbed_tickets.thumbs_direction@>
				<a href="@thumbed_tickets.thumbs_undo_url;noquote@">@thumbs_up_pressed_24;noquote@</a>
				</if>
				<else>
				<a href="@thumbed_tickets.thumbs_undo_url;noquote@">@thumbs_down_pressed_24;noquote@</a>
				</else>
			</td>
			<td class="list-narrow">
				<a href="@thumbed_tickets.idea_url;noquote@">@thumbed_tickets.project_name@</a>
				<br>
				#intranet-idea-management.Status#: @thumbed_tickets.ticket_status@
			</td>
		    </tr>
		</multiple>
		</table>

		<if @remaining_thumbs@ gt 0>
			You have @remaining_thumbs@ votes left to distribute
		</if>
		<else>
			All your @max_thumbs_count@ votes have been distributed.
		</else>

	<%= [im_box_footer] %>
	</td>
	</tr>
	</table>


</td>
</tr>
</table>



