function [S2G, W, M2] = quadratureS2Grid(bandwidth, varargin)
%
% Syntax
%   [S2G, W, M2] = quadratureS2Grid(M) quadrature grid of type chebyshev
%   [S2G, W, M2] = quadratureS2Grid(M, 'gauss') quadrature grid of type gauss
%


persistent S2G_p;
persistent W_p;
persistent M2_p;
persistent N_p;




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
  M2 = gridIndex.bandwidth(index);
  N = gridIndex.N(index);
else
  M2 = ceil(bandwidth/4)*4; % make the bandwidth multible of four
  N = (2*bandwidth+2)*(bandwidth+1);
end

if ~isempty(M2_p) && ~isempty(N_p) && M2_p == M2 && N_p == N
  S2G = S2G_p;
  W = W_p;
  M2 = M2_p;
  
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
  else
    bandwidth = bandwidth/2;
    ph = (-bandwidth-1:bandwidth)/(2*bandwidth+2)*2*pi;
    th = (0:bandwidth)/(bandwidth+1)*pi;
    [ph, th]=meshgrid(ph, th);
    S2G = vector3d.byPolar(ph, th);
    S2G = S2G(:);
    S2G.addOption('using_fsft');
    % one could implement this by using the dct
    v = 4./(1-4*(0:bandwidth/2).^2)';
    v(1) = v(1)/2;
    W = 1/(bandwidth+1)*cos(2*(0:bandwidth+1)'*(0:bandwidth/2)*pi/(bandwidth+1))*v;
    %W([1 end]) = W([1 end])/2; % we need those nodes twice
    W = [W; W(2:end-1)];
    W = pi*ones(bandwidth+1, 1)/(bandwidth+1)*W';
    W = W(:);
  end
  
  % store the data
  S2G_p = S2G;
  W_p = W;
  M2_p = M2;    
end

end
