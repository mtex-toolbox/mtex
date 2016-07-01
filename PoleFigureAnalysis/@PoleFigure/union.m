function pf = union(pf,varargin)
% crytsallographic direction to one
%
% Syntax
%   pf = union(pf)
%   pf = union(pf1,pf2,pf3)
%
% Input
%  pf, pf1, pf2 - @PoleFigure
%
% Output
%  pf  - @PoleFigure

pf = [pf,varargin{:}];
i = 2;

while i <= pf.numPF
  
  % any previous equal to current?
  match = arrayfun(@(j) all(pf.allH{i} == pf.allH{j}),1:i-1);
    
  % if duplication found
  if any(match)
    % combine current with duplicated pole figure
    pos = find(match);
    pf.allR{pos} = [pf.allR{pos}(:);pf.allR{i}(:)];
    pf.allI{pos} = [pf.allI{pos}(:);pf.allI{i}(:)];    
    
    % remove the current pole figure
    pf.allR(i) = [];
    pf.allH(i) = [];
    pf.allI(i) = [];
    pf.c(i) = [];
  else
    i = i + 1;
  end
  
end
end
