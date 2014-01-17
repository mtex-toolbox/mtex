function display(pf,varargin)
% standard output

disp(' ');
h = doclink('PoleFigure_index','PoleFigure');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp([h ' ' docmethods(inputname(1))]);

if isempty(pf), return;end

% display mineral name
if ~isempty(get(pf(1).CS,'mineral'))
  disp(['  mineral: ',get(pf(1).CS,'mineral')]);
end

disp(['  crystal symmetry : ',get(pf(1).CS,'name'),' (',...
  option2str([{get(pf(1).CS,'Laue')},get(pf(1).CS,'alignment')]) ')']);
disp(['  specimen symmetry: ',get(pf(1).SS,'name')]);
disp(' ');

for i = 1:length(pf)
  disp(['  ',char(pf(i),'short')]);
end
