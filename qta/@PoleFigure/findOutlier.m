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
lpf = cumsum([0,GridLength(pf)]);

ind = [];
for ipf = 1:length(pf)
  
  r = pf(ipf).r;
  
  % find neighbours
  next = find(r,vector3d(r),3*get(r,'resolution'));
  
  %remove diagonal
  next(speye(length(next))==1) = false;
  
  % compute mean
  dmean = next * pf(ipf).intensities(:) ./ sum(next,2);
  
  dstd = std(pf(ipf).intensities(:));
  
  ind = [ind;lpf(ipf) + find(abs(dmean - pf(ipf).intensities(:))>alpha*dstd)]; %#ok<AGROW>
  
end
