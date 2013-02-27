resumeditor
===========

A code base for displaying and editing resumes using MarkLogic

This is sample code for an application built around XSLTForms (a JavaScript/XML framework for bulding XForms files) and MarkLogic 6 Application Server.

A sample of this application is currently online at http://prototype.eccnet.com:8011/resume?id=KurtCagleResume1;face=edit

Currently supported interfaces include

  /resume/?id=_identifier_;face=xml GET - Retrieves the resume for the given identifier.

  /resume/?id=_identifier_;face=edit GET - Retrieves a view/edit page for the given resume.

  /resume/?face=xml POST - Posts an updated resume (with the identifier set to the value in /resume:resume/@id)

  /resume/?face=xml;q=_query-terms_ GET - Retrieves all resumes that match the query terms

  /resume/?face=xml;user=_userID_ GET - Retrieves all resumes that are owned by the given user

  /resume/?face=feed.xml;... GET - Retrieves a condensed feed of resume names and links, used primarily for populating lists.

  /resume/bio?id=_identifier_;face=xml GET - Retrieves just the biography information for the given resume.

  /resume/education?id=_identifier_;face=xml GET - Retrieves just the education information for the given resume.

  /resume/projects?id=_identifier_;face=xml GET - Retrieves just the projects (jobs) information for the given resume.````

Note that the semicolon and ampersand can be used interchangeably for parameters. 

Please note as well that there is a second application uploaded with this - the planetoids SVG/JavaScript game that
I developed for HTML5 Web Graphics with SVG and CSS for O'Reilly Media. This can be retrieved and played at http://prototype.eccnet.com:8011/lib/sandbox/game.svg
