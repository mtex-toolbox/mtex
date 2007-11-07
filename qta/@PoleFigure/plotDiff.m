function plotDiff(pfmeas,pfcalc,varargin)
% difference plot between two pole figures or an odf and a pole figure
%
%% Syntax
%  plotDiff(pf,pf2,<options>)
%  plotDiff(pf,odf,<options>)
%
%% Input
%  pf   - @PoleFigure
%  pf2  - @PoleFigure
%  odf  - @ODF     
%
%% Options
%  RP - calculate RP error
%  l1 - calculate l^1 error
%  l2 - calculate mean square error
%
%% See also
% S2Grid/plot PoleFigure/calcerror ODF/calcerror savefigure

plot(calcerrorpf(pfmeas,pfcalc,varargin{:}),varargin{:})
