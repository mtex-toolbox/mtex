function res = getResolution(pf)
% return resolution of pole figures
%
%% Input
% pf - @PoleFigure
%
%% Output
% res - resolution of the specimen directions in radians (double)

for i = 1:length(pf)
  res(i) = getResolution(getr(pf(i))); %#ok<AGROW>
end

res = max(res);
  
