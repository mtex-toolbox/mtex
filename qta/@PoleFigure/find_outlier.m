function ind = find_outlier(pf,varargin)
% find outliers in pole figures
%
%% Input
%  pf - @PoleFigure
%  
%% Options
%  alpha - double 
%
%% Output
%  ind - indece of the outliers
%
%% See also
% PoleFigure/delete


alpha = get_option(varargin,'alpha',2);
lpf = cumsum([0,GridLength(pf)]);

ind = [];
for ipf = 1:length(pf)
  
  r = pf(ipf).r;
  
  next = find(r,vector3d(r),3*get(r,'resolution'));
  
  dmean = (10 * next * pf(ipf).data(:) - pf(ipf).data) ./ (10*sum(next,2)-9);
  
  dstd = std(pf(ipf).data);
  
  ind = [ind;lpf(ipf) + find(abs(dmean - pf(ipf).data)>alpha*dstd)]; %#ok<AGROW>
  
end
