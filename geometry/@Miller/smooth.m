function varargout = smooth(m,varargin)
% plot Miller indece
%
% Input
%  m  - Miller
%
% Options
%
% See also
% vector3d/smooth

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

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
