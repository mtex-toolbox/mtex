function varargout = plot(sF,varargin)
%
% Syntax
%
% Input
%
% Output
%
% Options
%
% See also
%

% create a new figure if needed
%[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% get plotting region
sR = sF.s.fundamentalSector(varargin{:});

% set axes alignment
if isa(sF.s,'crystalSymmetry')
  varargin = [sF.s.plotOptions,varargin];
end

% perform plotting
[varargout{1:nargout}] = sF.plot@S2Fun(sR,varargin{:});


function txt = tooltip(varargin)

[h_local,value] = getDataCursorPos(mtexFig);

h_local = Miller(h_local,sF.s,'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end
