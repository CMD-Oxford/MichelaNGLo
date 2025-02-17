<h3>Protected page</h3>
<p>A page marked as publication-ready/published must remain stable for many years, therefore the following are enforced:
</p>
   <ul>
   <li>It is deletion protected</li>
   <li>A backup has been made</li>
   <li>prolink monitoring</li>
   </ul>
<p>The system will monitor every 10 days that the prolinks generate the same images and that the content is consistent with that stored.
   If something differs, the admin will be notified and action will be taken as follows:</p>
   <ol>
    <li><b>Bug</b>: the issue will be corrected if possible, else you will be contacted (extremely unlikely).</li>
    <li><b>Minor edit</b>*: no action. (&lowast;borrowing the definition from <a href="https://en.wikipedia.org/wiki/Help:Minor_edit">  Wikipedia <i class="far fa-external-link"></i></a>)</li>
    <li><b>Major edit</b>: you will be contacted to verify this was truly you.</li>
   </ol>
<p>At server reset and every 10 days a nodejs/puppeteer job is kicked off, which opens the page in Chromium and emulates mouseclicks on each link and saves an image. An image is considered a match is it's 99% identical.</p>
<p>A page that is encrypted cannot obviously be monitored.</p>
