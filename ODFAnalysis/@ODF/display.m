function display(odf,varargin)
% standard output

disp(' ');

% variable name
if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = '];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = '];
else
  h = [];
end

if isempty(odf)
  disp([h doclink('ODF_index','ODF') ' ' docmethods(inputname(1))]);
  disp(' ');
  return
end

% ODF / MDF
if isa(odf.SS,'crystalSymmetry') && isa(odf.CS,'crystalSymmetry')
  h = [h, doclink('MDF_index','MDF')];
else
  h = [h,doclink('ODF_index','ODF')];
end

disp([h ' ' docmethods(inputname(1))]);

% display symmtries and minerals
if ~isempty(odf.CS), disp(char(odf.CS,'verbose','symmetryType'));end
if ~isempty(odf.SS), disp(char(odf.SS,'verbose','symmetryType'));end
if odf.antipodal, disp('  antipodal:         true'); end

% display components
disp(' ');
for i = 1:length(odf.components)
  
  odf.components{i}.display;
  disp(['    weight: ',num2str(odf.weights(i))]);  
  disp(' ');
  
end
