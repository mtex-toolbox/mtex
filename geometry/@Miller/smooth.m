function varargout = smooth(m,varargin)
% contour plot of crystal directions
%
% Input
%  m  - @Miller
%
% Options
%  resolution - 
%  contour  -
%  contourf - 
%
% See also
% vector3d/smooth
%

% create a new figure if needed
mtexFig = newMtexFigure('datacursormode',@tooltip,varargin{:});

% get plotting region
sR = region(m,varargin{:});
    
% use vector3d/smooth for output
[varargout{1:nargout}] = smooth@vector3d(m,varargin{:},sR, m.CS, m.CS.how2plot);

function txt = tooltip(varargin)

[h_local,~,value] = getDataCursorPos(mtexFig);

h_local = Miller(h_local,m.CS,'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end
