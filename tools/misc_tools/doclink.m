function linkText = doclink(fname,lname)
% build a command window hyperlink to a documentation page
%
% The link runs mtexShowDoc rather than naming the html file directly: it
% keeps the link short enough to survive text wrapping, and it is the one
% place that decides whether the page comes from the local installation or
% from the web.
%
% Syntax
%   linkText = doclink('EBSDReferenceFrame','here')
%   linkText = doclink(ebsd)
%
% Input
%  fname - documentation page, or an object whose class page is meant
%  lname - text of the link, defaults to the page name
%
% See also
% mtexShowDoc
%

if nargin == 1
  if ischar(fname)
      lname = fname;
  else
    lname = class(fname);
  end
end
if ~ischar(fname), fname = [class(fname) '.' class(fname)]; end

linkText = ['matlab:mtexShowDoc(''' fname ''')'];

% check whether script is published
stack = dbstack;
if ~any(strcmp({stack.name},'publish'))

  % generate link text
  linkText = ['<a href="' linkText '" style="font-weight:bold">' lname '</a>'];

else
  linkText = lname;
end
