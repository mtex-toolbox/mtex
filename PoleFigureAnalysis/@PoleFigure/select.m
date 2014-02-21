function pf = select(pf,varargin)
% select PoleFigures
%
% Syntax:
%   pf.select(1)     % select the first pole figure
%   pf.select([1,2]) % select the first two pole figure

ind = subsind(pf,varargin{:});

pf.allH = pf.allH(ind);
pf.allR = pf.allR(ind);
pf.allI = pf.allI(ind);
pf.c = pf.c(ind);
