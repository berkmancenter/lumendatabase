# Submitter JavaScript widget
## What is this?
The submitter widget lets you to add a Lumedatabase widget to your website. The widget allows users to submit complaints and requests for removal of online materials on your website. This data will be automatically published in our system, you will be able to review it later using the Lumendatabase website.
## Where to start?
If you want to start using the widget you need to request access first here: https://lumendatabase.org/api_submitter_requests/new. We will review your request and respond as soon as possible (usually it shouldn't take more than 24 hours).
## I have access, what's next?
After we approve your application you will receive an email with your submitter token. You will need it to use the widget on your site.
The widget code is located here: https://lumendatabase.org/assets/widgets/submitter.js. We recommend to use it instead of using a copy of the file on your server, this helps keeping it up-to-date.
## Add submitter widget to website

 1. Add the widget code to your website.
```html
<script src="https://lumendatabase.org/assets/widgets/submitter.js"></script>
```
 2. Choose an HTML element that will be filled with the widget.
```html
<div id="lumen-widget"></div>
```
 3. Initialize the widget using JavaScript.
```html
<script>
  var lumen_submitter = LumenSubmitterWidget({
    element_selector: '#lumen-wrapper',
    public_key: 'wownag{ovOk0'
  });
</script>
```
`element_selector` is just an HTML selector of the widget container.

`public_key` is your widget token that you received in the confirmation email. Make sure to use it, otherwise users won't be able to submit anything.
## Test environment
If you want to submit test notices you can use our test instance of the Lumen Database: https://api-beta.lumendatabase.org/. Just request a new token here the same way as on the live site: https://api-beta.lumendatabase.org/api_submitter_requests/new and use the widget source code located here: https://api-beta.lumendatabase.org/assets/widgets/submitter.js. You can then submit dummy data to test your integration before making it live.

If possible, avoid submitting any dummy data to the live site, please 😉.
## Demo
To see a live demo of the widget visit this page: https://lumendatabase.org/submitter_widget_demo/index.html. The source code of the demo is here: https://github.com/berkmancenter/lumendatabase/blob/master/public/submitter_widget_demo/index.html. Feel free to use the form and submit new notices, they will be published on our test instance of the Lumen Database: https://api-beta.lumendatabase.org.
## Need help?
If you need help with integrating the widget create a new issue here: https://github.com/berkmancenter/lumendatabase/issues.
