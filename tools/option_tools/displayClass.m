function displayClass(obj,input,varargin)

if check_option(varargin,'skipHeader'), return; end

disp(' ');

cN = class(obj);
if nargin == 2, altName = cN; else, altName = varargin{1}; end

disp([input ' = ' doclink([cN '.' cN],altName) ' ' docmethods(input)]);
           
end
