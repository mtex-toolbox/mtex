function [traces, rel, cSize] =  calcTraces(ebsd,varargin)
% traces of subregions of an EBSD map
%
% Syntax
%
%   clusterId = [grainId,variantId];
%   [traces, rel, cSize] = calcTraces(ebsd, clusterId, 'Radon')
%
% Input
%  ebsd - @EBSD
%  clusterId  - an id indicating for which pixel form a region
%
% Output
%  traces - @vector3d size max(clusterId(:,1)) x max(clusterId(:,2)) ....
%  rel    - reliability index
%  cSize  - cluster size
%
% Options
%  minClusterSize - minimum number of pixels required for trace computation (default: 100) 
%  Radon   - Radon based algorithm
%  Fourier - Fourier based algorithm
%
% References
%
% * <https://arxiv.org/abs/2201.02103 Determination of child phase habit
% planes from two-dimensional reconstructed parent phase orientation maps>,
% arXiv, 2022
%

if ~isnull(angle(ebsd.N,zvector,'antipodal'))
  warning('not yet implemented')
end

% ensure EBSD is at a grid
[ebsd,newId] = ebsd.gridify;

if nargin > 1 && isnumeric(varargin{1})
  for k = 1:size(varargin{1},2)
    prop{k} = nan(size(ebsd));
    prop{k}(newId) = varargin{1}(:,k);
  end
else
  prop{1} = double(~isnan(ebsd));
end
sz = [cellfun(@(x) max(x(:)),prop),1];

xyz = nan(prod(sz),3);
rel = zeros(sz);

% determine cluster size
% this is a matrix with size "sz"
allProp = reshape([prop{:}],length(ebsd),[]);
cSize = accumarray(allProp(all(allProp>0,2),:),1);

% only consider sufficiently large clusters
ic = find(cSize > get_option(varargin,'minClusterSize',100));

method = get_flag(varargin,{'Radon','Fourier'},'Radon');
J = get_option(varargin,'cutOff',6);

% loop over all clusters
for i = 1:length(ic)
  
  progress(i,length(ic));

  % generate a cropped black white image of the cluster
  [sub{1:length(prop)}]  = ind2sub(sz,ic(i));
  X = prop{1} == sub{1};
  for j = 2:length(prop), X = X & prop{k} == sub{k}; end
  X = trimMat(X);
  
  switch lower(method)
    case 'radon'

      theta = (0:179)*degree;

      % Radon transform
      R = radon(X);

      % Fourier transform
      Y = fftshift(abs(fft(R,[],1)),1);

      % sum over all frequencies, while leaving out the smallest
      % frequencies, as they are dominated by the shape of the cluster

      Z = sum(Y(1:floor(end/2)-J,:));

      % take the maximum of the radon transform along the centerline
      % which correspondes to the lines passing through the center
      %[m,id] = max(smoothdata(Z,'gaussian',30));
      [m,id] = max(Z);

      xyz(ic(i),1) = cos(pi/2-theta(id));
      xyz(ic(i),2) = sin(pi/2-theta(id));     
      rel(ic(i)) = (m - mean(Z))./m;

    case 'fourier'
      
      mxy = (1 + size(X))./2;
      dr = min(mxy)/2;

      % Fourier transform image
      Y = rescale(abs(fftshift(fft2(X - mean(X(:))))));

      % post process Fourier transform
      % cut out outer circle - to reduce effect of the shape of the rectangle
      % for the radon transform
      [x,y] = meshgrid(1:size(Y,2),1:size(Y,1));
      r = sqrt((x-mxy(2)).^2+(y-mxy(1)).^2); % distance to center
      Y = Y .* (r<dr);

      M = Y(:) .* [x(:)-mxy(2),y(:)-mxy(1)];
      [lambda,xyz(ic(i),1:2),~] = eig2(M' * M);

      % reliability
      rel(ic(i)) = (lambda(2) - lambda(1))./lambda(2);

  end

end

xyz(~isnan(xyz(:,1)),3) = 0;
traces = reshape(vector3d(xyz.','antipodal'),sz);
end

