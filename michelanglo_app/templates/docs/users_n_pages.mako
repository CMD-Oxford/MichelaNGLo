<%namespace file="../layout_components/common_methods.mako" import="copy_btn"/>
<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>
<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>
<%block name="title">
            &mdash; Documentation
</%block>
<%block name="subtitle">
            Users and pages
</%block>

<%block name="main">
    <%include file="subparts/docs_nav.mako"/>


    ############################################################# Users
    <%include file="subparts/docs_users.mako"/>

    ######################################################### Pages
    <%include file="subparts/docs_pages.mako"/>
    <%include file="subparts/docs_protected.mako"/>
</%block>