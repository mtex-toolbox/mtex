function display(m,varargin)
% standard output

displayClass(m,inputname(1),'moreInfo',char(m.CS,'compact'),varargin{:});

display@vector3d(m,'skipHeader', 'skipCoordinates');

% display coordinates
if length(m) < 25 && ~isempty(m)
  
  eps = 1e4;
  
  % extract coordinates in the correct form
  d = round(m.coordinates * eps)./eps;
  
  % set up coordinate names
  columnNames = vec2cell(char(m.dispStyle));
      
  cprintf(d,'-L','  ','-Lc',columnNames);
  
end
