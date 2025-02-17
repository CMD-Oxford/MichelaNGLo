<%namespace file="../layout_components/labels.mako" name="info"/>
<%inherit file="../layout_components/layout_w_card.mako"/>

<%block name="buttons">
            <%include file="../layout_components/vertical_menu_buttons.mako" args='tour=False'/>
</%block>

<%block name="title">
            &mdash; Guiding links ("Prolinks")
</%block>

<%block name="subtitle">
            Construction of HTML anchor tags to guide the users to a residue or region
</%block>

<%block name="body">

    <%include file="subparts/docs_nav.mako"/>


<div class='row'>
            <div class='col-12 col-sm-6 mb-2'>

                <h3>Aims</h3>
                <p>This system to control the protein without any JS coding.</p>
                <h3>Demo</h3>
                <p>Let's look at the structure of GFP. Overall is <span class="prolink" data-toggle="protein" data-target="viewport" data-focus="domain" data-selection="11-228" data-color="lime">a &beta;-barrel</span>,
                    but sports <span class="prolink" data-toggle="protein" data-target="#viewport" data-selection="54-82" data-color="purple">a loop that traverses the core</span>.</p>
                <p>In this loop, there are <span class="prolink" data-toggle="protein" data-target="#viewport"  data-focus="residue" data-selection="65-67" data-radius="2">three residues, SYG,</span> that mature to form a chromophore.</p>
                <p>The camera can be set to <span class="prolink" href="#viewport" data-toggle="protein" data-view="[13.87245243079792,-18.27360233135557,63.99186261747443,0,-11.069766475366883,63.82311925112967,20.62517100777409,0,-65.62273457879594,-14.629178608334712,10.04847249632254,0,-0.7559999823570251,-65.44000244140625,5.427000045776367,1]" >predefined coordinates</span>.</p>
                <p>This can be combined to allow <span class="prolink" data-toggle="protein" data-target="#viewport"  data-focus="residue" data-selection="65-67" data-radius="2" data-view="[21.083709695256083,3.2638383176464822,-24.800012660489337,0,-25.012283268399123,3.115199733699885,-20.8541914098467,0,0.28098794552718936,32.40152732655437,4.503127326542097,0,-11.023754117672173,-71.66366796614918,6.221244923015376,1]">selection of a given set of residues, such as the chromophore, but to manually fix an obstructed view</span></p>
                <p>Also, setting the tolerance to really low <span class="prolink" data-toggle="protein" data-target="#viewport"  data-focus="clash" data-selection="29" data-tolerance="0.1">we can see residues spuriously clashing</span>.  </p>
                <p>Let's look at <span class="prolink" data-toggle="protein" data-target="viewport" data-focus="surface" data-title="surface">the surface</span>.</p>
                <p class="mb-3">Also, the B-factors can be seen in tube <span class="prolink" data-toggle="protein" data-target="viewport" data-focus="blur" data-title="B-factors">B-factors</span>.</p>
                <%include file="../markup/markup_builder_btn.mako"/>
            </div>
            <div class='col-12 col-sm-6'>
			<div id="viewport" style="width:100%; height: 0; padding-bottom: 100%; overflow: visible;"></div>
		</div>
<div class="col-12">
<p><i class="far fa-hand-point-right"></i> This page is running on NGL extended with the <a href="/static/michelanglo.js">file michelanglo.js</a></p>
                <h3>Markup</h3>

                <p>Following Bootstrap, the most common CSS framework, several <code>data-*</code> attributes are proposed and implemented to control what is shown. If you are unfamilar with the terms "attribute" or "element" see <a href="#basics">basics</a>.</p>
    <p>The first link is: <code>&lt;a href='#viewport' data-toggle="protein" data-focus="domain" data-selection="11-228:A" data-color="lime" &gt;a &beta;-barrel&lt;/a&gt;</code>. Actually, it is <code>&lt;span class="prolink" data-target="viewport" &hellip;&gt;&lt;/span&gt;</code> in order to add custom CSS styling (green).</p>
    <p>The attribute <code>data-toggle="protein"</code> is what tells the browser that the link controls the protein (<a href="#row_toggle">see below for more</a>), <code>data-focus="domain"</code> tells it how to zoom (domain | residue | clash | surface) to use, while <code>data-selection="11-228:A"</code> controls what to zoom into.</p>
    <h4>List of attributes for prolinks</h4>
    <table class="table table-striped">
        <thead>
        <tr>
            <th>Attribute</th>   <th>Default</th>  <th>Affects</th>   <th>Description</th>
        </tr>
        </thead>
        <tbody>
        <tr id="row_toggle">
            <td colspan="2"><code>data-toggle="protein"</code></td>
            <td>All</td>
            <td>Instructs that the anchor element (link) or similar element affects the protein. The michelanglo.js script add a monkeypatches JQuery with the prototype <code>protein</code>, then runs <code>$('[data-toggle="protein"]').protein();</code> so all relevant elements existing when the document is loaded are enabled. If new are added they have to be activated manually in JS with <code>$('whatever').protein()</code>.</td>
        </tr>
        <tr id="row_target">
            <td><code>data-target</code></td>
            <td><code>'#viewport'</code></td>
            <td>All</td>
            <td>If there is no stage on <code>#viewport</code> or there are multiple stages and they were stored in <code>NGL.stageId</code> (see <a href="note">note</a>), use the attribute  pointing towards an id with or without the hash. As anchor elements are not styled as hyperlinks unless you have a <code>href</code> attribute, an href is a valid alternative.</td>
        </tr>
        <tr id="row_focus">
            <td><code>data-focus</code></td>
            <td><code>domain</code></td>
            <td>&mdash;</td>
            <td>To control whether to focus on a large region/domain, on a few residues and their neighbourhood, surface, blur-factor or on a clash. the attribute <code>data-focus</code> can be used with the choice of terms <code>'domain'</code> (or <code>'region'</code>), <code>'residue'</code>, <code>'clash'</code>, <code>'bfactor'</code> (or <code>'blur'</code>) or <code>'surface'</code> respectively.</td>
        </tr>
        <tr id="row_selection">
            <td><code>data-selection</code></td>
            <td> &mdash; (compulsory for <code>data-focus</code> instructions, use <code>'*'</code> to select all)</td>
            <td><code>data-focus</code></td>
            <td>The selection is controlled with a <a href="http://nglviewer.org/ngl/api/manual/selection-language.html">valid NGL selection <i class="far fa-external-link"></i></a>, for example a range is '1-20:A'.</td>
        </tr>
        <tr id="row_color">
            <td><code>data-color</code></td>
            <td><code>'green'</code> (focus: domain) | <code>'hotpink'</code> (focus: residue)</td>
            <td><code>data-focus</code> (except <code>="surface"</code>)</td>
            <td>To specify a colour, add the attribute <code>data-color="HTML_color"</code> where "HTML_color" is a valid html colour name or hex code. In the case of <code>data-focus="blur"</code>, both <code>data-selection</code> and <code>data-color</code>, if present, control the residues to show.</td>
        </tr>
        <tr id="row_radius">
            <td><code>data-radius</code></td>
            <td><code>'5'</code> (Å)</td>
            <td><code>data-focus='residue'</code> and <code>data-focus='clash'</code></td>
            <td>Used to specify how many &Aring;mstrongs to expand around in residue zooming mode.</td>
        </tr>
        <tr id="row_tolerance">
            <td><code>data-tolerance</code></td>
            <td><code>'1'</code> (Å)</td>
            <td><code>data-focus='clash'</code></td>
            <td>The clashes are determined by finding distances less than the sum of the van der Waals radii. However, due to imprecise structures or sp2 orbitals it can be lower hence this optional factor</td>
        </tr>
        <tr id="title">
            <td><code>data-title</code></td>
            <td>Nothing shown</td>
            <td>All</td>
            <td>shows a temporary title, which is actually a label element with a for attribute pointing to the viewport id. Consequently if one wanted to override it's location one could add <code>&lt;label for="viewport">&lt;/label></code> where desired.</td>
        </tr>
        <tr>
            <td><code>data-hetero</code></td>
            <td><code>false</code></td>
            <td>All</td>
            <td>If true, will display hetero atoms (ligands), including waters. They will be displayed with element colours in licorice style with double bonds shown.</td>
        </tr>
        <tr>
            <td><code>data-load</code></td>
            <td>&mdash;</td>
            <td></td>
            <td>will load a new PDB, either as a 4 letter code or a index (see further). It plays well with data-focus or data-view, which are executed afterwards. However, a more powerful option is available thanks to the MultiLoader's loadFx.</td>
        </tr>
        <tr>
            <td><code>data-view</code></td>
            <td>&mdash;</td>
            <td></td>
            <td>accepts three possible values, one of these is an orientation matrix as begot from <code>stage.viewerControls.getOrientation()</code>. The 16-dimension vector can be used to manually correct residue selections (data-focus) by using both.</td>
        </tr>
        <tr>
            <td colspan="2"><code>data-view='auto'</code></td>
            <td></td>
            <td>Uses the <code>.autoView()</code> function, which translates without rotation.</td>
        </tr>
        <tr>
            <td colspan="2"><code>data-view='reset'</code></td>
            <td></td>
            <td>If the stage was loaded with the multiLoader() and a loadFx was supplied with the protein it will run that, otherwise it will do the same as auto.</td>
        </tr>
        <tr>
            <td><code>data-label</code></td>
            <td><code>true</code></td>
            <td><code>data-focus='residue'</code> and <code>data-focus='clash'</code></td>
            <td>Control whether a label on the residue is added or not &mdash;this is not the same as <code>data-title</code>, which controls the text under the scene.</td>
        </tr>
        <tr>
            <td><code>data-cartoonScheme</code></td>
            <td><code>'previous'</code></td>
            <td><code>data-focus='residue'</code> and <code>data-focus='clash'</code> in the precence of <code>data-load</code></td>
            <td>This command alters a fix for the case when the model is changed (_e.g._ a mutant is loaded) and therefore there is no colour information for the newly loaded cartoon.
                If set to <code>false</code> or <code>'none'</code> the cartoon will be set to white. Setting to <code>'previous'</code> will use the previous representation.
                While if set to a string corresponding to a NGL scheme it will use that scheme (_eg._ <code>"chainid"</code>).
                Do note that "previous" makes sense only if the new model loaded is a variant of the old one, otherwise it may behave oddly, therefore make sure to set <code>data-cartoonScheme</code> for those cases.
            </td>
        </tr>
        <tr>
            <td><code>data-selection-alt1</code><br/>(or higher number)</td>
            <td>—</td>
            <td>optionally <code>data-focus-alt1='residue'</code> and <code>data-color-alt1='red'</code></td>
            <td>This command adds an additionally selection without removing the previous —see <a href="#stacking">"stacking" paragraph</a>.
            </td>
        </tr>
        <tr>
            <td><code>data-focus-alt1</code><br/>(or higher number)</td>
            <td><code>'residue'</code></td>
            <td><code>data-selection-alt1='12:A'</code>. Optionally <code>data-color-alt1='red'</code></td>
            <td>This command adds an additionally selection without removing the previous —see <a href="#stacking">"stacking" paragraph</a>.
                The GUI only accepts residue | domain, but in reality other "focus" commands are accepted.
            </td>
        </tr>
        <tr>
            <td><code>data-color-alt1</code><br/>(or higher number)</td>
            <td><code>'green'</code></td>
            <td><code>data-selection-alt1='12:A'</code> and optionally <code>data-focus-alt1='domain'</code></td>
            <td>This command adds an additionally selection without removing the previous —see <a href="#stacking">"stacking" paragraph</a>.
            </td>
        </tr>
        </tbody>
    </table>

    <h4 id="stacking">Stacking of representations</h4>
    <p>The residue-focused selection keeps the domain-focused selection, because in the narration of a protein generally
    one speaks of the domain and then goes into detail about residues, therefore it is handy to keep the previous representation.
    For this logic, the reverse is not true.</p>
    <p>A different case happens with the alternative representations (<code>-alt1</code>, <code>-alt2</code> etc.).
    With these the previous representation is not blanked.
        Consequently highlighting a domain as an additional representation will <b>not</b> remove the previous ones.
        Therefore, one must give a domain-focused selection as the main selection and residue-focuses
        as a secondary selection, else the previous domain will stay and new domain-focuses selections will stack on top.
    </p>
    <h4>$('..').protein()</h4>
    <p>When the dom loads the links are automatically enabled, however, if new links are added dynamically you have to activate them using <code>$(...).protein()</code>, for example <code>$('[data-toggle="protein"]').protein();</code></p>


    <%include file="subparts/docs_viewport.mako"/>


    <h3 id="note">Note</h3>
                <p>There are a bunch of underlying functions. They are in the file: <a href="static/michelanglo.js">file ngl.extended.js</a>, which requires JQuery and NGL, which works as usual*. So at the end of your documents you should have:</p>
                <pre><code>
&lt;script src="https://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"&gt;&lt;/script&gt;
&lt;script src="https://unpkg.com/ngl@2.0.0-dev.34/dist/ngl.js" type="text/javascript"&gt;&lt;/script&gt;
&lt;script src="https://michelanglo.sgc.ox.ac.uk/michelanglo.js" type="text/javascript"&gt;&lt;/script&gt;
                </code></pre>
    <p>The CDN for <code>michelanglo.js</code> is <code>michelanglo.sgc.ox.ac.uk/michelanglo.js</code>, but if you are checking this out, you can sneakily use the last address, but please do not use it in production.</p>
            <p>&lowast;One issue is holding onto the stage object in JS. Therefore the stage is added as follows: <code>NGL.stageIds['viewport'] = new Stage( ...</code>. However, a better feature is using the <code>NGL.specialOps.multiLoad</code>, which handles it.</p>

                <h3 id="basics">Basic terms</h3>
                <p>A HTML page is formed by various elements with the following syntax: <code>&lt;ELEMENT attribute="value"&gt; text &lt;/ELEMENT&gt;</code>.
                    The first part, called the opening tag, contains attributes. These include the unique <code>id</code> and CSS controlling <code>style</code> attributes.</p>
                <p>A special convention exist to store custom data in <code>data-*</code> attributes. For example, <code>&lt;span id='blaId' data-hello='world'&gt;bla bla&lt;span&gt;</code> appears simply as "bla bla" in the browser, but the JS can access this data, e.g. using JQuery <code>$('#blaId').data('hello')</code> one gets <code>world</code> back.</p>

        </div>
        </div>
</%block>

<%block name='modals'>
<%include file="../markup/markup_builder_modal.mako"/>
</%block>
<%block name="script">
    <script type="text/javascript">
        $(document).ready(function () {
            NGL.specialOps.showTitle('viewport', '<i class="far fa-dna fa-spin"></i> Loading...');
            NGL.specialOps.multiLoader('viewport', [{type: 'url', value: '/static/gfp.pdb'}]);
        });
        <%include file="../markup/markup_builder_modal.js"/>
    </script>
</%block>

