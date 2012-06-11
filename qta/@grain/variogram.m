function varargout = variogram(grains, varargin)
% calculate the experimental semivariogram for a property, where the
% distances are based on the centroids
%
%% Input
% grains   - @grain
% property - string or array
%
%% Options
% nbins    - number of bins
% clouds   - if plotting, plot data points
%
%% Syntax
%
% variogram(grains,'property')  - plot
% [yh h] = variogram(grains,...)  - 
% [yh h n bins ystd] = variogram(grains,...) - 
%

xy = centroid(grains);
x = xy(:,1);
y = xy(:,2);

name = 'semivariogram';
if nargin > 1
  p = varargin{1};
  
  if any(strcmpi(p, fields(grains(1).properties)))
    name = [p ' - '  name];
    p = get(grains,p);
    %what to do with quaternions?
  end
  
end
 
xx = repmat(x,size(grains));
yy = repmat(y,size(grains));

%E = mean(p);
pp = repmat(p(:),size(grains));

X = ((pp-pp').^2);%/(numel(pp));
dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2));

X = X(:);
dist = dist(:);

if length(p)/2 < 50, 
  nb = length(p)/2;
else nb = 50; end

nbins = get_option(varargin,'nbins',nb);
[n h] =  hist(dist,nbins);
bins = [ 0 h+[h(2)-h(1) diff(h)]/2];

gam = zeros(size(n));
err = zeros(size(n));
for k=1:length(h)
  Z = X(bins(k) <= dist & dist <= bins(k+1));
  gam(k)= sum(Z)/n(k); %mean
  err(k) = sqrt(sum((Z-gam(k)).^2)/numel(Z)); %std
end


if nargout == 0
  subplot(3,1,1:2)
  if check_option(varargin,'cloud')
    ind = fix(rand(1,20000)*length(X));
    plot(dist(ind),X(ind),'.','color',[0.6 0.6 1]);
    m = [min(X) max(X)];
    hold on
  else 
    m = [min(gam) max(gam)];
  end
  plot(h,gam ,'.-')
  xlabel('h'); ylabel('y(|h|)')
  title( name )
    axis tight
    grid on

  subplot(3,1,3)
  errorbar(h,gam,err,'*')
  xlabel('h') ;ylabel('std(|h|)')
    axis tight
    grid on
elseif nargout > 0
  varargout{1} =  gam;
  varargout{2} =  h;
  varargout{3} =  n;
  varargout{4} =  bins;
  varargout{5} =  err;  
end
