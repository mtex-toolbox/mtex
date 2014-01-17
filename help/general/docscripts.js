// Toggle a division as expanded or collapsed.
// Also toggle the arrow icon.
// Refer to the division and image by their IDs.
//
// "Collapsed" material is hidden using the
// display property in CSS.

// Used by adaptproduct function (see below)
// to support adaptive doc in the Windows
// version of the Help Browser.
var adaptiveIds = new Array();

function toggleexpander(blockid, arrowid) {
   arrow = document.getElementById(arrowid);
   block = document.getElementById(blockid);
   if (block.style.display == "none") {
      // Currently collapsed, so expand it.
      block.style.display = "block";
      arrow.src = "arrow_down.gif";
      arrow.alt = "Click to Collapse";
   }
   else {
      // Currently expanded, so collapse it.
      block.style.display = "none";		
      arrow.src = "arrow_right.gif";
      arrow.alt = "Click to Expand";
   }
   return false; // Make browser ignore href.
}

// ===================================================
// Adapt doc content based on installed licenses. 
// Refer to the div or span by its ID.
//
// This code supports both the Unix version of
// the Help Browser, which supports LiveConnect (i.e.,
// JavaScript<->Java interaction, and the Windows
// version, which does not support LiveConnect but does
// support a MathWorks-specific feature intended to support
// adaptive doc. Specifically, when
// the Windows version loads an HTML page, it checks
// whether the page defines a variable adaptiveDocPresent
// with a value of true. If the page defines the variable,
// the Help Browser invokes the function doAdaptiveDoc (see
// below) when the page has finished loading to show or hide 
// adaptive sections.
function adaptproduct(license,id) {

   try {
     // Works only if the Help Browser supports LiveConnect, i.e.,
     // the Unix version.
     if (!Packages.com.mathworks.mlservices.MLLicenseChecker.hasLicense(license)) {
      thisel = document.getElementById(id);
      thisel.style.display = 'none';
     };
   } catch(e) {
      // Help Browser does not support Live Connect. Assume
      // that it supports doAdaptiveDoc and save the license
      // and adaptive element id for use by doAdaptiveDoc.
      adaptiveIds[adaptiveIds.length] = license + '|' + id;
   }

}

// ===================================================
// Invoked by the Windows version of the Help Browser if 
// the page being displayed sets
//
//   adaptiveDocPresent = true
//
// Products is a list of the product licenses owned by the
// user.
function doAdaptiveDoc(products) {
  for (i = 0; i < adaptiveIds.length; i++) {
    adaptiveInfo = adaptiveIds[i].split('|');
    if (products.indexOf(adaptiveInfo[0]) < 0) {
      thisel = document.getElementById(adaptiveInfo[1]);
      thisel.style.display = 'none';
    }
  }
}

// ===================================================
// Create and uniquely name two levels of upward navigation buttons
// for Functions -- By Category pages

var top_button_count = 0;
var current_section_id = 0;

function addTopOfPageButtons()
{

top_button_count = top_button_count + 1;

var top_of_page_buttons =

"<a class=\"pagenavimglink\" href=\"#top_of_page\" onMouseOver=\"document.images.uparrow" +
top_button_count +
".src=\'doc_to_top_down.gif\'\;\" onMouseOut=\"document.images.uparrow" +
top_button_count +
".src=\'doc_to_top_up.gif\'\;\"><img style=\"margin-top:0;margin-bottom:0px;padding-top:0;padding-bottom:0\" border=0 src=\"doc_to_top_up.gif\"  alt=\"Back to Top of Page\" title=\"Back to Top of Page\" name=\"uparrow" +
top_button_count +
"\">\&nbsp\;</a>";

document.write(top_of_page_buttons);
}


function updateSectionId(id)
{
current_section_id = id;
}


function addTopOfSectionButtons()
{

top_button_count = top_button_count + 1;

var top_of_page_buttons =

"<a class=\"pagenavimglink\" href=" +
"\"#" + current_section_id + "\"" +
" onMouseOver=\"document.images.uparrow" +
top_button_count +
".src=\'doc_to_section_down.gif\'\;\" onMouseOut=\"document.images.uparrow" +
top_button_count +
".src=\'doc_to_section_up.gif\'\;\"><img style=\"margin-top:0;margin-bottom:0px;padding-top:0;padding-bottom:0\" border=0 src=\"doc_to_section_up.gif\"  alt=\"Back to Top of Section\" title=\"Back to Top of Section\" name=\"uparrow" +
top_button_count +
"\">\&nbsp\;</a>";

document.write(top_of_page_buttons);
}

// ===================================================
// Create and write to the document stream HTML for 
// the link to the Doc Feedback Survey site.
//
// Doing this through a JavaScript function is necessary
// to work around the an issue with pages that are found
// through the search facility of the help browser--
//
// When found as the result of a search, 
// the document that is displayed in the Help browser
// is actually a temporary document with a trivial URL
// such as "text://5", not an actual page location.
//
// But the Help browser inserts a <BASE> element at the beginning
// of each such temporary page, and the <BASE> element stores the
// actual location. 
//
// So this function tests the URL of the document for the expression "text://"
// and if that expression is found, attempts to use the URL stored in
// the <BASE> element.

function writeDocFeedbackSurveyLink()
{
 var queryexpression = document.location.href;
 var istempsearchpage = false;
 
 if (queryexpression.search(/text:\/\//) != -1)
 {
  var baseelement = document.getElementsByTagName("BASE")[0];
  queryexpression = baseelement.href;
 }
 survey_url_yes = "http://www.customersat3.com/TakeSurvey.asp?si=YU2FDmNEifg%3D&SF=" + queryexpression + "-YES";
 survey_url_no = "http://www.customersat3.com/TakeSurvey.asp?si=YU2FDmNEifg%3D&SF=" + queryexpression + "-NO";
 
 code = '<div style="padding-right:10px">' + '<strong>Was this topic helpful?</strong> <input type="button" value="Yes" onClick="openWindow(\'' + survey_url_yes + '\',850,680, \'scrollbars=yes,resizable=yes\'); return false;"/>' + '&nbsp;&nbsp;' + '<input type="button" value="No" onClick="openWindow(\'' + survey_url_no + '\',850,680, \'scrollbars=yes,resizable=yes\'); return false;"/>' + '</div>';
 document.write(code);
}


// Utility function replacing openWindow function used by the web-site survey link code.
// In the help browser, the original code would create a blank window before loading the URL into the system browser.
function openWindow ( url, width, height, options, name ) {
  // ignore the arguments, except url
  document.location = url;
} // end function openWindow



// ===================================================

// Copyright 2002-2010 The MathWorks, Inc.
