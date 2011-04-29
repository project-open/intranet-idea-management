
<if @show_template_p@>
<master>
<property name="title">@page_title@</property>
<property name="context_bar">@context_bar@</property>
<property name="sub_navbar">@idea_navbar_html;noquote@</property>
</if>

<script type="text/javascript">
Thumbs_up_pale = new Image();
Thumbs_up_pale.src = "@thumbs_up_pale_24_gif;noquote@";
Thumbs_up_pressed = new Image();
Thumbs_up_pressed.src = "@thumbs_up_pressed_24_gif;noquote@";

function thumbs_change (name, object) {
  window.document.images[name].src = object.src;
}
</script>

<if @show_template_p@>
<table>
<tr valign=top>
<td width="60%">
</if>

	<h1>@page_title@</h1>
        <p>#intranet-idea-management.Description_of_activities#</p>
	
	<form method=post action="/intranet-helpdesk/action">
	<%= [export_form_vars {return_url} ] %>

	
	<table class="list">
	
	    <tr class="list-header">
		<if @user_is_admin_p@>
		<th class="list-narrow" align=center>
			<input type=checkbox name="_dummy" onclick="acs_ListCheckAll('idea_list', this.checked)" title="Check/uncheck all rows">
		</th>
		</if>
		<th class="list-narrow">#intranet-idea-management.Votes#</th>
		<th class="list-narrow">#intranet-idea-management.Name#</th>
	    </tr>
	
	<multiple name=ideas>
	    <if @ideas.rownum@ odd><tr class="list-odd" valign=top></if> 
	    <else><tr class="list-even" valign=top></else>
	
		<if @user_is_admin_p@>
		<td class="list-narrow">
			<input type=checkbox name=tid value=@ideas.idea_id@ id='ticket,@ideas.idea_id@'>
		</td>
		</if>
	
		<td align=center>
			<div style="width: 50px; height: 35px;	border: solid 1px #ccc; -moz-border-radius: 5px; -webkit-border-radius: 5px; border-radius: 5px; text-align: center">
			<div style="color: #333; margin-bottom: -0.1em; letter-spacing: -1px; font-weight: bold; font-size: 200%">
			<if "" ne @ideas.thumbs_up_count@>
			@ideas.thumbs_up_count@
			</div>
			<if 1 eq @ideas.thumbs_up_count@>#intranet-idea-management.Thumb#</if>
			<else>#intranet-idea-management.Thumbs#</else>
			</div>
			</if>
	
			<if "up" eq @ideas.thumbs_direction@>
			<a href="@ideas.thumbs_undo_url;noquote@" onmouseover="thumbs_change('thumbs_@ideas.rownum@', Thumbs_up_pale)" onmouseout="thumbs_change('thumbs_@ideas.rownum@', Thumbs_up_pressed)">
				<img src="@thumbs_up_pressed_24_gif;noquote@" name="thumbs_@ideas.rownum@" title="#intranet-idea-management.Press_here_to_redraw_your_vote_for_this_idea#" border='0' style='margin-top:3px'></a><br>
			</if>
			<else>
			<a href="@ideas.thumbs_up_url;noquote@" onmouseover="thumbs_change('thumbs_@ideas.rownum@', Thumbs_up_pressed)" onmouseout="thumbs_change('thumbs_@ideas.rownum@', Thumbs_up_pale)">
				<img src="@thumbs_up_pale_24_gif;noquote@" name="thumbs_@ideas.rownum@" title="#intranet-idea-management.Press_here_to_vote_for_this_idea#" border='0' style='margin-top:3px'></a><br>
			</else>
	
		</td>
	
		<td class="list-narrow">
			<a href="@ideas.idea_url;noquote@">@ideas.project_name@</a>
			<br>
			@ideas.idea_description;noquote@
			<br>
			#intranet-idea-management.From#: <a href="@ideas.creator_url;noquote@">@ideas.creator_name@</a>
			|
			<a href="@ideas.idea_url;noquote@">
			@ideas.comment_count@ 
			<if @ideas.comment_count@ eq 1>#intranet-idea-management.Comment#</if>
			<else>#intranet-idea-management.Comments#</else></a>
			| 
			<if @ideas.comment_count@>
			</if>
			#intranet-idea-management.Status#: @ideas.ticket_status@
			|
			#intranet-idea-management.Type#: @ideas.ticket_type@
			|
			<a href="@ideas.comments_url;noquote@"
			><%= [im_gif comments [lang::message::lookup "" intranet-idea-management.Comment_on_idea "Comment on idea"]] 
			%></a>
			|
			<a href="@ideas.dollar_url;noquote@"
			><%= [im_gif money_dollar [lang::message::lookup "" intranet-idea-management.Share_development_costs "Share development costs"]] 
			%></a>
	
		</td>
	    </tr>
	</multiple>


<if @ticket_bulk_actions_p@>
	<tfoot>
	<tr valign=top>
	  <td align=left colspan=3 valign=top>
		<%= [im_category_select \
			     -translate_p 1 \
			     -package_key "intranet-helpdesk" \
			     -plain_p 1 \
			     -include_empty_p 1 \
			     -include_empty_name "" \
			     "Intranet Ticket Action" \
			     action_id \
			]
		%>
		<input type=submit value='#intranet-helpdesk.Update_Tickets#'>
	  </td>
	</tr>
	</tfoot>
</if>

	</table>
	</form>


<if @show_template_p@>
</td>
<td align=left width="40%">
</if>

	<h1><%= [lang::message::lookup "" intranet-idea-management.Your_Votes "Your Votes"] %></h1>
	<if @thumb_count@>

		<table class="list" width="100%">
		    <tr class="list-header">
			<th class="list-narrow">#intranet-idea-management.Votes#</th>
			<th class="list-narrow">#intranet-idea-management.Name#</th>
		    </tr>
		<multiple name=thumbed_tickets>
		    <if @thumbed_tickets.rownum@ odd><tr class="list-odd" valign=top></if> 
		    <else><tr class="list-even" valign=top></else>

			<td class="list-narrow">
				<if "up" eq @thumbed_tickets.thumbs_direction@>
				<a href="@thumbed_tickets.thumbs_undo_url;noquote@">
					<img src="@thumbs_up_pressed_24_gif;noquote@" title="#intranet-idea-management.Press_here_to_redraw_your_vote_for_this_idea#">
				</a>
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
			You have still @remaining_thumbs@ votes left to distribute.
		</if>
		<else>
			All of your @max_thumbs_count@ votes have been distributed.
		</else>

	</if>
	<else>
		<p>
		<font color=red>
		Please click on the @thumbs_up_pale_24;noquote@ icons on the left<br>
		hand side in order to vote for your ideas.
		</font>
		</p>
	</else>

	<br>&nbsp;<br>


	<if @survey_count@></if>
	<else>
	<h1>#intranet-idea-management.Increase_the_Weight_of_your_Votes#</h1>
	#intranet-idea-management.You_havent_yet_filled_our_one_of_the_following_surveys#.<br>
	#intranet-idea-management.Filling_out_the_survey_will_increase_the_weight_of_your_votes#:<br>
	&nbsp;

	<ul>
	<li>Are you a potential ]po[ user?<br>
		Then please take the <a href="/simple-survey/one?return_url=&survey_id=438275">Potential User Feedback</a>
		<br>&nbsp;
	<li>Are you a productive ]po[ user?<br>
		Then please take the <a href="/simple-survey/one?return_url=&survey_id=438249">Productive User Feedback</a>
		<br>&nbsp;
	<li>Are you a ]po[ partner? <br>
		Then please take the <a href="/simple-survey/one?return_url=&survey_id=305439">Partner Survey</a>.
		<br>&nbsp;
	</ul>
	</else>

	<h1>Create a new Idea</h1>
	<p>
	#intranet-idea-management.Please_check_for_duplicate_ideas#
	</p>
	<form action="/intranet-idea-management/idea-new" method=POST>
	<%= [export_form_vars return_url] %>
	<table width="100%">
	<tr class=rowodd>
	<td>#intranet-idea-management.Title#:</td>
	<td><input type=text size=40 name=idea_title value="#intranet-idea-management.Catchy_phrase_for_your_idea#"></td>
	</tr>
	<tr class=roweven>
	<td>#intranet-idea-management.Description#:</td>
	<td><textarea name=idea_description cols=30 rows=3>#intranet-idea-management.One_or_two_paragraphs_to_describe_your_idea#</textarea></td>
	</tr>
	<tr class=rowodd>
	<td>#intranet-idea-management.Submit#:</td>
	<td><input type=submit></td>
	</tr>
	</table>
	</form>


<if @show_template_p@>
</td>
</tr>
</table>
</if>



