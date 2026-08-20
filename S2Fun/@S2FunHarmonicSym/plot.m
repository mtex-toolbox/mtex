function varargout = plot(sF,varargin)
%
% Syntax
%
%   plot(sF)
%
% Input
%  sF - @S2FunHarmonicSym
%
% See also
% S2Fun/plot

% create a new figure if needed
%[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% get plotting region
if sF.antipodal, varargin = [varargin,'antipodal']; end
sR = sF.s.fundamentalSector(varargin{:});

% perform plotting
% sF.how2plot, not sF.s.how2plot - a convention set on the function itself
% has to win over the one of its reference system
%
% appended as a marked fallback rather than as a bare object, so that a plot
% that wants to choose its own camera when the caller named no convention
% can see that this one is ours and not theirs - @vector3d/plot3d does
[varargout{1:nargout}] = sF.plot@S2Fun(sR,sF.s,varargin{:},'how2plotFallback',sF.how2plot);


function txt = tooltip(varargin)

[h_local,~,value] = getDataCursorPos(mtexFig);

h_local = Miller(h_local,sF.s,'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end
