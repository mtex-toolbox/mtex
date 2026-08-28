function display(v,varargin)
% standard output

if check_option(varargin,'onlyShowVectors')
  d = [v.x(:),v.y(:),v.z(:)];
  d(abs(d) < 1e-10) = 0;

  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'},'-n','%.3g');
  return
end

if check_option(varargin,'onlyShowMiller')
  eps = 1e4;
  % extract coordinates in the correct form
  d = round(v.coordinates * eps)./eps;
  % set up coordinate names
  columnNames = vec2cell(char(v.dispStyle));
  cprintf(d,'-L','  ','-Lc',columnNames);
  return
end

% a direction in a crystal frame is headed by the frame and listed in its
% indices; any other one by the convention it is drawn in and its
% coordinates
isCrystal = isCrystalDirection(v);

if isCrystal
  header = char(v.CS,'compact');
else
  % the frame together with the convention the data is drawn in - an own
  % convention override wins and is shown plainly
  header = referenceFrame.headerChar(v.frame,v.how2plot);
end

displayClass(v,inputname(1),'moreInfo',header,varargin{:});

if length(v) ~= 1, disp([' size: ' size2str(v)]);end

if v.antipodal, disp(' antipodal: true'); end

% display resolution
if isOption(v,'resolution')
  disp([' resolution: ',xnum2str(getOption(v,'resolution')/degree),mtexdegchar]);
  v.opt = rmfield(v.opt,'resolution');
end

% display all other options
disp(char(dynOption(v)));

% display coordinates
if check_option(varargin,'skipCoordinates') || isempty(v)

elseif check_option(varargin,'all') || (length(v) < 20)

  if isCrystal, display(v,'onlyShowMiller'); else, display(v,'onlyShowVectors'); end

elseif ~getMTEXpref('generatingHelpMode')

  disp(' ')
  s = setAllAppdata(0,'data2beDisplayed',v);
  if isCrystal
    disp(['  <a href="matlab:display(getappdata(0,''',s,'''),''onlyShowMiller'')">show Miller</a>'])
  else
    disp(['  <a href="matlab:display(getappdata(0,''',s,'''),''onlyShowVectors'')">show vectors</a>'])
  end
  disp(' ')

end
