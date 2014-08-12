function [m,r] = string2Miller(s,CS)
% converts string to Miller indece

r = 1;
if nargin == 1, CS = crystalSymmetry('m-3m'); end

try
  % extract filename
  s = s(max([1,1+strfind(s,filesep)]):end);
  
  % first try to extract 4 Miller indice
  e = regexp(fliplr(s),'([0123456]-? ?){4}','match');
  m = exp2Miller(e,CS);
  if ~isempty(m), return;end
  
  % if this fails try to extract only 3 Miller indice without minus
  e = regexp(fliplr(s),'([0123456] ?){3}','match');
  m = exp2Miller(e,CS);
  if ~isempty(m), return;end
  
  % if this fails as well try to extract 3 Miller indice with minus
  e = regexp(fliplr(s),'([0123456]-? ?){3}','match');
  m = exp2Miller(e,CS);
  if ~isempty(m), return;end
  
  % if this fails set to default value and report
catch, end

m = Miller(1,0,0,CS);
r = 0;

% ----------------------------------------------------------------
function m = exp2Miller(e,CS)

if isempty(e), m = []; return, end

m = Miller(CS);
for i = 1:length(e)
  try
    m(end+1) = Miller(fliplr(e{i}),CS);
  catch, end
end

if ~isempty(m)
  m = fliplr(m);
else
  m = [];
end
