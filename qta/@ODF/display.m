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
end;

if isempty(odf)
  disp([h doclink('ODF_index','ODF') ' ' docmethods(inputname(1))]);
  disp(' ');
  return
end

csss = {'sample symmetry ','crystal symmetry'};

% symmetries
cs = odf(1).CS;
ss = odf(1).SS;

% ODF / MDF
if isCS(ss) && isCS(cs)
  h = [h, doclink('MDF_index','MDF')];
else
  h = [h,doclink('ODF_index','ODF')];
end

disp([h ' ' docmethods(inputname(1))]);

% display symmtries and minerals
disp(['  ' csss{isCS(cs)+1} ': ', char(cs,'verbose')]);
disp(['  ' csss{isCS(ss)+1} ': ',char(ss,'verbose')]);

% display components
disp(' ');
for i = 1:length(odf)
  
  odf(i).doDisplay;
  disp(['    weight: ',num2str(odf(i).weight)]);  
  disp(' ');
  
end
