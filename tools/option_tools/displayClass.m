function displayClass(obj,input,varargin)

if check_option(varargin,'skipHeader'), return; end

disp(' ');

cN = class(obj);
if nargin == 2 || isempty(varargin{1}), altName = cN; else, altName = varargin{1}; end

if check_option(varargin,'moreInfo')
  disp([input ' = ' doclink([cN '.' cN],altName) ' (' ...
    get_option(varargin,'moreInfo') ')']);
else
  disp([input ' = ' doclink([cN '.' cN],altName) ' ' docmethods(input)]);
end       
end
