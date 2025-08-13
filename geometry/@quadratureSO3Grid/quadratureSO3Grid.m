classdef (InferiorClasses = {?rotation,?quaternion}) quadratureSO3Grid < orientation
% Compute nodes and weights for quadrature on SO(3).
% 
% Description
%
% The following quadrature rules are implemented:
%
% * |'ClenshawCurtis'| combines the Gauss quadrature in 1st and 3rd Euler
% angle (alpha, gamma) with Clenshaw Curtis quadrature in 2nd Euler angle
% (beta)
%
% * |'GaussLegendre'| combines the Gauss quadrature in 1st and 3rd Euler
% angle (alpha, gamma) with Gauss Legendre quadrature in 2nd  Euler angle
% (beta)
%
% Syntax
%   SO3G = quadratureSO3rid(N, 'ClenshawCurtis')
%   [SO3G, W] = quadratureSO3rid(N,CS,SS,'ClenshawCurtis') % quadrature grid of type Clenshaw Curtis
%
% Input
%  N - bandwidth
%  CS,SS  - @symmetries
%
% Output
%  SO3G - @orientation grid
%  W - quadrature weights
%
% Options
%  ClenshawCurtis - use Clenshaw Curtis quadrature nodes and weights (default)
%  GaussLegendre - use Gauss Legendre quadrature nodes and weights
%
% See also
% regularSO3Grid  SO3FunHarmonic/quadrature

% TODO: Save storage with: Define quadratureSO3Grid as own class with 
% properties 
%   bandwidth
%   CS
%   SS
%   scheme = 'ClenshawCurtis'
% end
% and methods SLeft, SRight, orientation
% and reconstruct orientations if needed (subsref function)

properties
  weights = []
  scheme = 'ClenshawCurtis'
  iuniqueGrid
  ifullGrid
end

properties (Dependent=true)
  bandwidth
  uniqueGrid
  fullGrid
end

methods

  function SO3G = quadratureSO3Grid(varargin)
  
    persistent keepSO3G;

    % ---------------------------------------------------------------------
    % Construct new quadratureSO3Grid from some given grid by adjusting
    % properties like the bandwidth, symmetries or scheme
    if nargin>0 && isa(varargin{1},'quadratureSO3Grid')
      g = varargin{1};
      
      % extract symmetry
      isSym = cellfun(@(x) isa(x,'symmetry'),varargin,'UniformOutput',true);
      if any(isSym)
        CS = varargin{find(isSym,1)};
        isSym(find(isSym,1)) = 0;
      else
        CS = g.CS;
      end
      if any(isSym)
        SS = varargin{find(isSym,1)};
      else
        SS = g.SS;
      end

      % extract scheme
      if check_option(varargin,'GaussLegendre')
        scheme = 'GaussLegendre';
      elseif check_option(varargin,'ClenshawCurtis')
        scheme = 'ClenshawCurtis';
      else
        scheme = g.scheme;
      end
      
      % extract bandwidth
      N = get_option(varargin,'bandwidth');
      if ~isempty(N)
        quadratureSO3Grid.check_bandwidth(N,CS,SS,scheme);
      else
        [~,N] = quadratureSO3Grid.adjust_bandwidth(g.bandwidth,CS,SS);      
      end

      SO3G = quadratureSO3Grid(N,CS,SS,scheme);
      return
    end

    % ---------------------------------------------------------------------
    % get bandwidth
    if nargin>0 && isnumeric(varargin{1}) && isscalar(varargin{1})
      N = varargin{1};
    else
      N = get_option(varargin,'bandwidth', getMTEXpref('maxSO3Bandwidth'));
    end
    % get symmetries
    [SRight,SLeft] = extractSym(varargin);
    % get quadrature scheme
    if check_option(varargin,'GaussLegendre')
      scheme = 'GaussLegendre';
    else
      scheme = 'ClenshawCurtis';
    end

    if isa(keepSO3G,'quadratureSO3Grid') && keepSO3G.bandwidth == N && ...
        keepSO3G.CS == SRight && keepSO3G.SS == SLeft && strcmp(keepSO3G.scheme,scheme)
      SO3G = keepSO3G;
      return
    end

    % check whether it is suitable
    quadratureSO3Grid.check_bandwidth(N,SRight,SLeft,scheme);
  
    % Do not use 'antipodal' for evaluation or quadrature grid
    varargin = delete_option(varargin,'antipodal');
   
    % The quadrature method itself only uses Z-fold rotational symmetry axis
    % (only use cyclic symmetry axis)
    sym = {'1','112','3','4','','6'};
    if isa(SRight,'crystalSymmetry')
      SRightNew = crystalSymmetry(sym{SRight.multiplicityZ});
    else
      SRightNew = specimenSymmetry(sym{SRight.multiplicityZ});
    end
    if isa(SLeft,'crystalSymmetry')
      SLeftNew = crystalSymmetry(sym{SLeft.multiplicityZ});
    else
      SLeftNew = specimenSymmetry(sym{SLeft.multiplicityZ});
    end
  
    % Construct quadrature nodes
    nodes = regularSO3Grid(scheme,'bandwidth',2*N,SRightNew,SLeftNew,varargin{:},'ABG');
    nodes.CS = SRight; nodes.SS = SLeft;
    [u,inodes,iu] = quadratureSO3Grid.uniqueQuadratureSO3Grid(N,scheme,nodes.CS,nodes.SS);
    SO3G.CS = SRight;
    SO3G.SS = SLeft;
    SO3G.a = u.a; SO3G.b = u.b;
    SO3G.c = u.c; SO3G.d = u.d;
    SO3G.i = u.i; SO3G.antipodal = nodes.antipodal;    
    SO3G.iuniqueGrid = iu;
    SO3G.ifullGrid = inodes;
    s = size(nodes);
  
    % Construct Weights
    if check_option(varargin,'GaussLegendre')
      [~,w] = legendreNodesWeights(N+1,-1,1);
    else
      w = quadratureSO3Grid.fclencurt2(2*N+1);
      if s(2) == 1+N
        w = w(1:size(nodes,2));
      end
    end
    % W = normalized volume * 2xGauß-quadrature-weights * Clenshaw-Curtis-quadrature-weights
    % W =     1/sqrt(8*pi^2)    *      (2*pi/(2*N+2))^2     *              w_b^N
    SO3G.weights = repmat(w'/(2*s(1)*s(3)),s(1),1,s(3));
    SO3G.scheme = scheme;

    keepSO3G = SO3G; % remember grid for future usage

  end


  function N = get.bandwidth(SO3G)
    s = size(SO3G.iuniqueGrid);
    if strcmp(SO3G.scheme,'GaussLegendre')
      N = s(2)-1;
    else
      N = (s(2)-1)/2;
    end
  end

  function SO3G = set.bandwidth(SO3G,N)
    SO3G = quadratureSO3Grid(N,SO3G.CS,SO3G.SS,SO3G.scheme);
  end

  function nodes = get.uniqueGrid(SO3G)
    nodes = orientation(SO3G);
  end

  function u = get.fullGrid(SO3G)
    quadratureSO3Grid.check_bandwidth(SO3G.bandwidth,SO3G.CS,SO3G.SS,SO3G.scheme)
    u = SO3G.uniqueGrid.subSet(SO3G.iuniqueGrid);
  end

end

methods (Static = true, Hidden = true)

  function [bwSmall,bwLarge] = adjust_bandwidth(N,SRight,SLeft)
    % compute the nearest bandwidth that is suitable to the symmetries for 
    % fast computations of the adjoint SO3-Fourier/Wigner transform inside 
    % of the SO3FunHarmonic.quadrature method
    [~,~,g] = fundamentalRegionEuler(SRight,SLeft,'ABG');
    LCM = lcm((1+double(round(2*pi/g/SRight.multiplicityZ) == 4))*SRight.multiplicityZ,SLeft.multiplicityZ);
    bwSmall = N;
    while mod(2*bwSmall+2,LCM)~=0
      bwSmall = bwSmall-1;
    end
    bwLarge = N;
    while mod(2*bwLarge+2,LCM)~=0
      bwLarge = bwLarge+1;
    end
  end

  function check_bandwidth(N,SRight,SLeft,scheme)
    % check whether the bandwidth is suitable to the symmetries for fast
    % computations of the adjoint SO3-Fourier/Wigner transform inside of 
    % the SO3FunHarmonic.quadrature method
    [bwSmall,bwLarge] = quadratureSO3Grid.adjust_bandwidth(N,SRight,SLeft);
    if bwSmall~=N
      error(['When trying to evaluate the function on ' ,scheme,...
             ' quadrature grid with bandwidth %i using the symmetries, ' ...
             'an error was detected. The specified bandwidth does not fit the ' ...
             'symmetries. Use bandwidth %i or %i instead.'],N,bwSmall,bwLarge);
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

  [u,inodes,iu] = uniqueQuadratureSO3Grid(N,scheme,varargin);
  
end

end



