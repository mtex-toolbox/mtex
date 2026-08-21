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
% sF.how2plot, not sF.s.how2plot - and appended as a marked fallback, so that a
% plot choosing its own camera can tell it apart from a convention of the caller
[varargout{1:nargout}] = sF.plot@S2Fun(sR,sF.s,varargin{:},'how2plotFallback',sF.how2plot);


function txt = tooltip(varargin)

[h_local,~,value] = getDataCursorPos(mtexFig);

h_local = Miller(h_local,sF.s,'uvw');
h_local = round(h_local,'tolerance',3*degree);
txt = [xnum2str(value) ' at ' char(h_local)];

end

end
