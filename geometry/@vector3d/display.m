function display(v,varargin)
% standard output

if check_option(varargin,'onlyShowVectors')
  d = [v.x(:),v.y(:),v.z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
  return
end

displayClass(v,inputname(1),varargin{:});%...
  %'moreInfo',char(v.refSystem,'compact'),varargin{:});

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
if check_option(varargin,'skipCoordinates') 

elseif (check_option(varargin,'all') || (length(v) < 20 && ~isempty(v)))
  
  display(v,'onlyShowVectors')

else

  disp(' ')
  setappdata(0,'data2beDisplayed',v);
  disp('  <a href="matlab:display(getappdata(0,''data2beDisplayed''),''onlyShowVectors'')">show Vectors</a>')
  disp(' ')

end