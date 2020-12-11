function display(v,varargin)
% standard output

vname = get_option(varargin,'name',inputname(1));
varargin = delete_option(varargin,'name',1);
displayClass(v,vname,varargin{:});

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
if ~check_option(varargin,'skipCoordinates') && ...
    (check_option(varargin,'all') || (length(v) < 20 && ~isempty(v)))
  
  d = [v.x(:),v.y(:),v.z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end
