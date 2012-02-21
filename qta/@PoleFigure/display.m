function display(pf,varargin)
% standard output

disp(' ');
h = doclink('PoleFigure_index','PoleFigure');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

if ~isempty(char(pf.comment)) 
  if all(equal(char(pf.comment),1)) 
    s = [' (',pf(1).comment];
  else
    s = ' (';
    for i=1:length(pf)
      s = [s, pf(i).comment]; %#ok<AGROW>
      if i~=length(pf), s = [s ', ']; end %#ok<AGROW>
    end
  end

  if length(s) > 60
    h = [h, s(1:60) '...'];
  else
    h = [h,s];
  end
  h = [h,')'];
end

disp(h);

disp(' ');

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

disp(docmethods(inputname(1)));
