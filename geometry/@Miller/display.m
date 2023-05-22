function display(m,varargin)
% standard output

if check_option(varargin,'onlyShowMiller')
  eps = 1e4;
  % extract coordinates in the correct form
  d = round(m.coordinates * eps)./eps;
  % set up coordinate names
  columnNames = vec2cell(char(m.dispStyle));
  cprintf(d,'-L','  ','-Lc',columnNames);
  return
end

displayClass(m,inputname(1),'moreInfo',char(m.CS,'compact'),varargin{:});

display@vector3d(m,'skipHeader', 'skipCoordinates');

% display coordinates
if length(m) < 20 && ~isempty(m)
  
  display(m,'onlyShowMiller')

elseif ~getMTEXpref('generatingHelpMode') && ~isempty(m)

  disp(' ')
  s = setappdata(0,'data2beDisplayed',m);
  disp(['  <a href="matlab:display(getappdata(0,''',s,'''),''onlyShowMiller'')">show Miller</a>'])
  disp(' ')

end
