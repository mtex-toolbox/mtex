function display(m,varargin)
% standard output

displayClass(m,inputname(1),varargin{:});

display@vector3d(m,'skipHeader', 'skipCoordinates');

% display symmetry
if ~isempty(m.CS.mineral)
  disp([' mineral: ',char(m.CS,'verbose')]);
else
  disp([' symmetry: ',char(m.CS,'verbose')]);
end

% display coordinates
if length(m) < 20 && ~isempty(m)
  
  eps = 1e4;
  
  % extract coordinates in the correct form
  d = round(m.coordinates * eps)./eps;
  
  % set up coordinate names
  columnNames = vec2cell(char(m.dispStyle));
      
  cprintf(d,'-L','  ','-Lc',columnNames);
  
end
