classdef quadratureS2Grid < vector3d
% Compute nodes and weights for quadrature on Sphere.
% 
% Description
%
% The following quadrature rules are implemented:
%
% * |'optimal'| is an optimal precomputed quadrature grid with low number 
% of quadrature points
%
% * |'ClenshawCurtis'| combines the Gauss quadrature in polar angle (theta) 
% with Clenshaw Curtis quadrature in azimuth angle (rho)
%
% * |'GaussLegendre'| combines the Gauss quadrature in in polar angle (theta)
% with Gauss Legendre quadrature in azimuth angle (rho)
%
% Syntax
%   S2G = quadratureS2Grid(N)
%   S2G = quadratureS2Grid(N, 'GaussLegendre')
%
% Input
%  N - bandwidth
%
% Output
%  S2G - @quadratureS2Grid
%
% Options
%  chebychev - optimal grid of chebychev style (default)
%  gauss - optimal grid of gaussian style
%  ClenshawCurtis - use Clenshaw Curtis quadrature nodes and weights (default)
%  GaussLegendre - use Gauss Legendre quadrature nodes and weights
%
% See also
% regularS2Grid  S2FunHarmonic/quadrature

properties
  weights = []
  scheme = 'optimal'
  name = '';
end

properties (SetAccess = immutable)
  bandwidth
end

methods

  function S2G = quadratureS2Grid(varargin)
  
    persistent keepS2G;

    % get bandwidth
    if nargin>0 && isnumeric(varargin{1}) && isscalar(varargin{1})
      N = varargin{1};
    else
      N = get_option(varargin,'bandwidth', getMTEXpref('maxS2Bandwidth'));
    end

    % get quadrature scheme
    if check_option(varargin,'GaussLegendre')
      scheme = 'GaussLegendre';
    elseif check_option(varargin,'ClenshawCurtis')
      scheme = 'ClenshawCurtis';
    else
      scheme = 'optimal';
    end

    % choose an optimal quadrature grid
    if strcmp(scheme,'optimal')
      if check_option(varargin, 'gauss')
        load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_gauss.mat'),'gridIndex');
      else
        load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_chebyshev.mat'),'gridIndex');
      end
      index = find(gridIndex.bandwidth >= 2*N, 1);
      if isempty(index)
        warning(['M is too large for useing an precomputed optimal quadrature grid. ' ...
          'Instead we use GaussLegendre quadrature.']);
        S2G = quadratureS2Grid(varargin{:},'GaussLegendre');
        return
      end

      M2 = floor(gridIndex.bandwidth(index)/2);

      if ~isempty(keepS2G) && keepS2G.bandwidth == M2 && strcmp(keepS2G.scheme,'optimal')
        S2G = keepS2G;
      return
      end
  
      name = cell2mat(gridIndex.name(index));
      if check_option(varargin, 'gauss')
        S2G.name = ['gauss: ',name];
        data = load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_gauss.mat'),name,['W_',name]);
      else
        S2G.name = ['chebychev: ',name];
        data = load(fullfile(mtexDataPath,'vector3d','quadratureS2Grid_chebyshev.mat'),name);
      end
  
      data = cell2mat(struct2cell(data));
      nodes = vector3d.byPolar(data(:, 1), data(:, 2));
      S2G.x = nodes.x; S2G.y = nodes.y; S2G.z = nodes.z;
    
      if check_option(varargin, 'gauss')
        S2G.weights = data(:,3);
      else
        S2G.weights = 4*pi/size(data, 1) .* ones(size(S2G));
      end

      S2G.scheme = scheme;
      S2G.bandwidth = M2;

      return
    end

    % Maybe use last grid again
    if isa(keepS2G,'quadratureS2Grid') && keepS2G.bandwidth == N && ...
        strcmp(keepS2G.scheme,scheme)
      S2G = keepS2G;
      return
    end

    % Construct quadrature nodes and weights
    if strcmp(scheme,'GaussLegendre')
      [nodes,w] = legendreNodesWeights(N+1,-1,1);
      theta = acos(nodes);
    else
      theta = (0:2*N)'*pi/(2*N);
      w = quadratureSO3Grid.fclencurt2(2*N+1);
    end
    rho = (0:2*N+1)*pi/(N+1);
    nodes = vector3d.byPolar(theta,rho);
    S2G.x = nodes.x; S2G.y = nodes.y; S2G.z = nodes.z;
    
    % W =   phi-weights   *   theta-weights
    % W =   2*pi/(2*N+2)  *        w_j
    S2G.weights = repmat(pi*w/((N+1)),1,2*N+2);

    S2G.scheme = scheme;
    S2G.bandwidth = N;

    keepS2G = S2G; % remember grid for future usage

  end

end

end



