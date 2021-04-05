function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')  
  c = option2str([{s.pointGroup},s.alignment]);
  if ~isempty(s.mineral), c = [s.mineral ' (' c ')']; end  
elseif check_option(varargin,'latex')
  c = ['$' regexprep(s.pointGroup,'-(\w)','\\bar{$1}') '$'];
elseif check_option(varargin,'compact')  
  if ~isempty(s.mineral)
    c = s.mineral; 
  else
    c = s.pointGroup;
  end
  
  if ~getMTEXpref('generatingHelpMode')
    id = pushTemp(s);
    c = ['<a href="matlab: display(pullTemp(' int2str(id) '),''vName'',''sym'')">' c '</a>'];
  end
else
  c = ['"',s.pointGroup,'"'];
end

if check_option(varargin,'symmetryType'), c = ['  crystal symmetry : ' c]; end
