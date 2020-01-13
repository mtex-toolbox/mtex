function [S3G, W, M2] = quadratureSO3Grid(bandwidth, varargin)
%
% Syntax
%   [S3G, W, M2] = quadratureSO3Grid(M) quadrature grid of type chebyshev
%   [S3G, W, M2] = quadratureSO3rid(M, 'gauss') quadrature grid of type gauss
%


persistent S3G_p;
persistent S3GW_p;
persistent S3GM2_p;

if check_option(varargin, 'gauss')
  load(fullfile(mtexDataPath,'orientation','quadratureSO3Grid_gauss.mat'),'gridIndex');
else
  load(fullfile(mtexDataPath,'orientation','quadratureSOGrid_chebyshev.mat'),'gridIndex');
end
index = find(gridIndex.bandwidth >= bandwidth, 1);
if isempty(index)
  index = size(gridIndex,1);
  warning('M is too large, instead we are giving you the largest quadrature grid we got.');
end

M2 = gridIndex.bandwidth(index);

if ~isempty(S3GM2_p) && S3GM2_p == M2
  S3G = S3G_p;
  W = S3GW_p;
  M2 = S3GM2_p;
  
else
  name = cell2mat(gridIndex.name(index));
  if check_option(varargin, 'gauss')
    data = load(fullfile(mtexDataPath,'orientation','quadratureS2Grid_gauss.mat'),name);
  else
    data = load(fullfile(mtexDataPath,'orientation','quadratureS2Grid_chebyshev.mat'),name);
  end

  data = data.(name);
  S3G = rotation.byEuler(data(:, 1), data(:, 2), data(:, 3));
  
  if check_option(varargin, 'gauss')
    W = data(:,4);
  else
    W = 4*pi/size(data, 1) .* ones(size(S3G));
  end  
  
  % store the data
  S3G_p = S3G;
  S3GW_p = W;
  S3GM2_p = M2;    
end

end
