function check_wraptext
% wrapping text for the command window, hyperlinks included
%
% wraptext is what every multi line message MTEX prints goes through - the
% reference frame notes of the importers, check_mex, the HDF5 configuration
% banner. Two of its rules are about hyperlinks, and both were broken in a
% way nothing could notice: the message still appeared, only the link in it
% no longer worked.
%
% The cause was that MATLAB regexp has no \b for a word boundary - \b is a
% backspace character - so the pattern '<a\b.*?>.*?</a>' that was supposed to
% find the anchors never matched anything, and an anchor was then wrapped
% like ordinary words: broken at the space in front of its style attribute,
% leaving the command window with markup it could not turn into a link, and
% counted by the 80 odd characters of its markup rather than by the four
% characters it puts on screen.
%
% See also
% wraptext doclink

checkPlainText;
checkAnchorStaysWhole;
checkAnchorCountsAsItsText;
checkParagraphs;

disp('check_wraptext: passed');

end

% =========================================================================
function checkPlainText
% the basic contract: no line over the width, no word split

width = 40;
out = wraptext(strjoin(repmat({'lorem','ipsum','dolor'},1,10),' '),width);

lines = split(string(out),newline);

assert(all(strlength(lines) <= width), ...
  'check_wraptext: a wrapped line is %d characters wide, the width was %d', ...
  max(strlength(lines)), width)

assert(isequal(strjoin(cellstr(lines),' '), strjoin(repmat({'lorem','ipsum','dolor'},1,10),' ')), ...
  'check_wraptext: wrapping changed the words')

end

% =========================================================================
function checkAnchorStaysWhole
% a line may never be broken inside an <a ...>...</a>
%
% This is the assertion that matters: a newline between the href and the
% style attribute leaves the command window printing the markup instead of a
% link, and nothing in the output looks wrong until someone tries to click it.

link = doclink('EBSDReferenceFrame','here');

assert(contains(link,' '), ...
  ['check_wraptext: doclink no longer produces an anchor with a space in it, ' ...
   'so this test can no longer see whether anchors survive wrapping'])

for width = [20 40 71 80 200]

  out = wraptext(['Click ' link ' for more information about it all.'],width);

  for ln = split(string(out),newline).'
    assert(count(ln,'<a ') == count(ln,'</a>'), ...
      ['check_wraptext: at width %d a line came out with %d opening and %d ' ...
       'closing anchor tags - the anchor was broken across lines'], ...
      width, count(ln,'<a '), count(ln,'</a>'))
  end

  % and nothing of the markup may be lost or reordered on the way
  assert(contains(replace(string(out),newline,' '),link), ...
    'check_wraptext: at width %d the anchor did not survive intact', width)

end

end

% =========================================================================
function checkAnchorCountsAsItsText
% an anchor takes up the width of its link text, not of its markup
%
% Otherwise a four character link pushes the words around it onto lines of
% their own, and the paragraph a note is printed as falls apart.

link = doclink('EBSDReferenceFrame','here');
width = 71;

out = wraptext(['Click ' link ' for more information.'],width);

assert(count(string(out),newline) == 0, ...
  ['check_wraptext: ''Click here for more information.'' is 32 visible ' ...
   'characters but was wrapped over %d lines at width %d - the anchor is ' ...
   'being measured by its markup'], count(string(out),newline)+1, width)

% two links and enough words to need exactly one break
long = ['Click ' link ' for more information, and see also ' ...
  doclink('EBSDImport','the import page') ' plus some further trailing words.'];

lines = split(string(wraptext(long,width)),newline);
visible = regexprep(lines,'<[^>]*>','');

assert(all(strlength(visible) <= width), ...
  'check_wraptext: a line is %d visible characters wide, the width was %d', ...
  max(strlength(visible)), width)

end

% =========================================================================
function checkParagraphs
% existing newlines are paragraph breaks and have to survive as they are

out = wraptext(sprintf('one\n\ntwo'),40);

assert(isequal(out,sprintf('one\n\ntwo')), ...
  'check_wraptext: the blank line between two paragraphs did not survive')

end
