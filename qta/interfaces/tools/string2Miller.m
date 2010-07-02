function [m,r] = string2Miller(s)
% converts string to Miller indece

r = 1;

try
  % extract filename
  s = s(max([1,1+strfind(s,'/')]):end);

  % first try to extract 4 Miller indice
  e = regexp(fliplr(s),'([0123456]-? ?){4}','match');
  m = exp2Miller(e);
  if ~isempty(m), return;end
  
  % if this fails try to extract only 3 Miller indice without minus
  e = regexp(fliplr(s),'([0123456] ?){3}','match');
  m = exp2Miller(e);
  if ~isempty(m), return;end
  
  % if this fails as well try to extract 3 Miller indice with minus
  e = regexp(fliplr(s),'([0123456]-? ?){3}','match');
  m = exp2Miller(e);
  if ~isempty(m), return;end
  
% if this fails set to default value and report
catch  

end

m = Miller(1,0,0);
r = 0;

  function m = exp2Miller(e)
       
    m = Miller;
    for i = 1:length(e)
      try
        ss = regexp(fliplr(char(e{i})),'-?\d','match');
        ss = cellfun(@(x) str2double(x),ss,'UniformOutput',0);
        [mm,er] = Miller(ss{:});
        if ~er, m(end+1) = mm; end       %#ok<AGROW>
      catch
      end
    end
    if numel(m)>0
      m = fliplr(m);
    else
      m = [];
    end
