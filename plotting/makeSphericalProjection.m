function proj = makeSphericalProjection(varargin)
%
% Input
% sR - @sphericalRegion
% v  - @vector3d
%
% Output
%  proj - @sphericalProjection
%
% Options
%  complete, lower, upper - decide on the spherical part
%  

ax = get_option(varargin,'parent',gca);
if ishold(ax) && isappdata(ax,'sphericalPlot')
  sP = getappdata(ax,'sphericalPlot');
  proj = sP.proj;
  return
end

% ------- extract plotting region ---------------
% default values from the vectors to plot
if nargin >= 1 && isa(varargin{1},'vector3d')
  sR = varargin{1}.region(varargin{2:end});
else
  sR = sphericalRegion;
end
sR = getClass(varargin,'sphericalRegion',sR);

% get plotting convention
how2plot = getClass(varargin,'plottingConvention',getMTEXpref('xyzPlotting'));

% check for simple options
if check_option(varargin,{'complete','3d'})
  sR = sphericalRegion;
end
if check_option(varargin,'upper')
  sR = sR.restrict2Upper(how2plot);
elseif check_option(varargin,'lower')
  sR = sR.restrict2Lower(how2plot);
end

% extract antipodal
sR.antipodal = sR.antipodal || check_option(varargin,'antipodal');

% for antipodal symmetry reduce to halfsphere
if sR.antipodal && sR.isUpper(how2plot) && sR.isLower(how2plot) &&...
    ~check_option(varargin,{'complete','3d'})
  sR = sR.restrict2Upper(how2plot);
end

% initialize the projections
if check_option(varargin,'3d')
  proj = '3d';
else
  proj = get_option(varargin,'projection','earea');
end

if ~isa(proj,'sphericalProjection')

  switch proj
    case 'plain', proj = plainProjection(sR);
    
    case {'stereo','eangle'}, proj = eangleProjection(sR,how2plot); % equal angle
      
    case 'edist', proj = edistProjection(sR,how2plot); % equal distance

    case {'earea','schmidt'}, proj = eareaProjection(sR,how2plot); % equal area
        
    case 'orthographic',  proj = orthographicProjection(sR,how2plot);
    
    case 'square',  proj = squareProjection(sR,how2plot);
      
    case 'gnonomic', proj = gnonomicProjection(sR,how2plot);

    case '3d',  proj = full3dProjection(sR,how2plot);

    otherwise
    
      error('%s\n%s','Unknown projection specified! Valid projections are:',...
        'plain, stereo, eangle, edist, earea, schmidt, orthographic','square')
  end
end

if ~isa(proj,'full3dProjection') && ~isa(proj,'plainProjection') && sR.isUpper(how2plot) && sR.isLower(how2plot)
  proj = [proj,proj];
  proj(1).sR = proj(1).sR.restrict2Upper(how2plot);
  proj(2).sR = proj(2).sR.restrict2Lower(how2plot);
end

end
