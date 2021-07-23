function [S2G, W, bandwidth] = quadratureS2Grid(bandwidth, varargin)
%
% Syntax
%   [S2G, W, M2] = quadratureS2Grid(M) quadrature grid of type chebyshev
%   [S2G, W, M2] = quadratureS2Grid(M, 'gauss') quadrature grid of type gauss
%

persistent S2G_p;
persistent W_p;
persistent bw_p;

if check_option(varargin, 'gauss') || check_option(varargin, 'chebyshev')
  if check_option(varargin, 'gauss')
    load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_gauss.mat'),'gridIndex');
  elseif check_option(varargin, 'chebyshev')
    load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_chebyshev.mat'),'gridIndex');
  end
  index = find(gridIndex.bandwidth >= bandwidth, 1);
  if isempty(index)
    index = size(gridIndex,1);
    warning('M is too large, instead we are giving you the largest quadrature grid we got.');
  end
  bandwidth = gridIndex.bandwidth(index);
  N = gridIndex.N(index);
elseif check_option(varargin,'clenshawCurtis')
  bandwidth = 2*ceil(bandwidth/2); % ensure bandwidth to be even
  N = (bandwidth+1)*(bandwidth+2);
else
  bandwidth = 2*ceil(bandwidth/2); % ensure bandwidth to be even
  N = (bandwidth+1)*(bandwidth/2+1);
end

if ~isempty(bw_p) && bw_p == bandwidth && length(S2G_p) == N
  S2G = S2G_p;
  W = W_p;
  bandwidth = bw_p;
  
else
  if check_option(varargin, 'gauss') || check_option(varargin, 'chebyshev')
    name = cell2mat(gridIndex.name(index));
    if check_option(varargin, 'gauss')
      data = load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_gauss.mat'),name);
    else
      data = load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_chebyshev.mat'),name);
    end
    
    data = data.(name);
    S2G = vector3d.byPolar(data(:, 1), data(:, 2));

    if check_option(varargin, 'gauss')
      W = data(:,3);
    else
      W = 4*pi/size(data, 1) .* ones(size(S2G));
    end  
  elseif check_option(varargin,'clenshawCurtis')
    S2G = regularS2Grid('clenshawCurtis','bandwidth',bandwidth);
    
    w = fclencurt2(size(S2G,1));
    W = 2*pi/size(S2G,2)*repmat(w,1,size(S2G,2));

    %W = W(:);
  else
    S2G = regularS2Grid('FSFT','bandwidth',bandwidth);
    
    w = fclencurt2(size(S2G,1));
    W = 2*pi/size(S2G,2)*repmat(w,1,size(S2G,2));
  end
  
  % store the data
  S2G_p = S2G;
  W_p = W;
  bw_p = bandwidth;    
end

end

function w = fclencurt2(n)

c = zeros(n,2);
c(1:2:n,1) = (2./[1 1-(2:2:n-1).^2 ])';
c(2,2)=1;
f = real(ifft([c(1:n,:);c(n-1:-1:2,:)]));
w = 2*([f(1,1); 2*f(2:n-1,1); f(n,1)])/2;
%x = 0.5*((b+a)+n*bma*f(1:n1,2));

end


