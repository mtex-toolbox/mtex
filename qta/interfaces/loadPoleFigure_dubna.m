function pf = loadPoleFigure_dubna(fname,varargin)
% load dubna cnv file 
%
%% Syntax
% pf = loadPoleFigure_dubna(fname,<options>)
%
%% Input
%  fname - file name
%
%% Options
%  STANDARD_GRID - use reguar 5 degree grid
%  DUBNA_GRID    - use original rotated Dubna grid
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% loadPoleFigure dubna_demo ImportPoleFigureData

try
  d = load(fname);
catch
  interfaceError(fname);
end

if ~isa(d,'double') || mod(numel(d),72)~=0 ||...
    numel(d)<3*72 || numel(d)>40*72
  interfaceError(fname);
end
  
d = reshape(d.',72,[]);

h = string2Miller(fname);
c = ones(1,length(h));

if check_option(varargin,'CNV') || strcmp(fname((end-2):end),'cnv')...
    && ~check_option(varargin,'REGULAR')
  r = DubnaGrid(size(d,2));
else
  r = S2Grid('regular','points',size(d),'maxtheta',5*degree*(size(d,2)-1),'antipodal');
end
  
pf = PoleFigure(h,r,d,symmetry('cubic'),symmetry,...
  'superposition',c,varargin{:});
