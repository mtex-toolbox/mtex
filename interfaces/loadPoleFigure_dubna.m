function pf = loadPoleFigure_dubna(fname,varargin)
% load dubna cnv file 
%
% Syntax
%   pf = loadPoleFigure_dubna(fname)
%
% Input
%  fname - file name
%
% Options
%  STANDARD_GRID - use reguar 5 degree grid
%  DUBNA_GRID    - use original rotated Dubna grid
%
% Output
%  pf    - @PoleFigure
%
% See also
% loadPoleFigure dubna_demo ImportPoleFigureData

% ensure right extension
[pathstr, name, ext] = fileparts(fname); %#ok<ASGLU>
if ~any(strcmpi(ext,{'.cnv','.cns'}))
  interfaceError(fname);
end

% load data
try
  d = load(fname);
catch
  interfaceError(fname);
end

% ensure sufficients data
if ~isa(d,'double') || mod(numel(d),72)~=0 ||...
    numel(d)<3*72 || numel(d)>40*72
  interfaceError(fname);
end
  
d = reshape(d.',72,[]);
h = string2Miller(fname);

switch lower(ext)
  case '.cnv'
    r  = DubnaGrid(size(d,2));
  case '.cns'
    r = regularS2Grid('points',size(d),'maxtheta',5*degree*(size(d,2)-1),'antipodal');
end

pf = PoleFigure(h,r,d,varargin{:});
