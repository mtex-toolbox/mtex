function display(gL,varargin)
% standard output
%
% A layout is two directions and nothing else, so it fits in the header -
% written the way a crystal alignment is, |row||y, col||x|, since that is
% the same kind of statement: which named axis a thing runs along.

info = {};
if ~isempty(gL.name), info{end+1} = gL.name; end

b = gL.basis;
info{end+1} = [gL.axesNames{1} '||' axisChar(b(1)) ', ' ...
  gL.axesNames{2} '||' axisChar(b(2))];

displayClass(gL,inputname(1),'moreInfo',strjoin(info,', '),varargin{:});

end

% =========================================================================
function s = axisChar(v)
% a direction as the axis it is, when it is one

names = {'x','y','z'};
xyz = [xvector, yvector, zvector];

for k = 1:3
  if abs(dot(v,xyz(k)) - 1) < 1e-6, s = names{k}; return; end
  if abs(dot(v,xyz(k)) + 1) < 1e-6, s = ['-' names{k}]; return; end
end

s = ['(' char(v) ')'];

end
