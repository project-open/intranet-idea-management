<master>
<property name="title">@page_title@</property>
<property name="context_bar">@context_bar@</property>

<h1>@page_title@</h1>
<p>
<%= [lang::message::lookup "" intranet-idea-management.Share_development_costs_msg "
Would you be willing to share the costs of implementing this idea?<br>
Please tell us how much you would be willing to pay to have this feature
working in your \]project-open\[ instance.<br>
We will contact you once enough offers have been collected to start the
implementation.<br>
"]%>
</p>

<br>&nbsp;<br>
<form action="/intranet-idea-management/dollar-action-2" method=POST>
<%= [export_form_vars ticket_id return_url] %>
<table>
<tr>
  <td><%= [lang::message::lookup "" intranet-idea-management.I_would_offer "I would offer:"] %></td>
  <td><input type=text name=amount size=5></td>
  <td><%= [ad_parameter -package_id [im_package_cost_id] "DefaultCurrency" "" "EUR"] %></td>
</tr>
<tr>
  <td></td>
  <td colspan=2><input type=submit></td>
</tr>
</table>
</form>

