function res = getResolution(pf)
% return resolution of pole figures
%
%% Input
% pf - @PoleFigure
%
%% Output
% res - resolution of the specimen directions in radiant (double)

res = getResolution(getr(pf));
