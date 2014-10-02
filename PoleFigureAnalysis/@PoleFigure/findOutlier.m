function ind = findOutlier(pf,varargin)
% find outliers in pole figures
%
% Input
%  pf - @PoleFigure
%  
% Options
%  alpha - double 
%
% Output
%  ind - indece of the outliers
%
% See also
% PoleFigure/delete

alpha = get_option(varargin,'alpha',2);

ind = [];
for ipf = 1:pf.numPF
  
  % find neighbours
  next = find(pf.allR{ipf},pf.allR{ipf},3*pf.allR{ipf}.resolution);
  
  %remove diagonal
  next(speye(length(next))==1) = false;
  
  % compute mean
  dmean = next * pf.allI{ipf}(:) ./ sum(next,2);
  
  dstd = std(pf.allI{ipf}(:));
  
  ind = [ind;abs(dmean - pf.allI{ipf}(:))>alpha*dstd]; %#ok<AGROW>
  
end
