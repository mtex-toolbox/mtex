function [value,pos] = min(sF, varargin)
% global, local and pointwise minima of spherical functions
%
% Syntax
%   [value,pos] = min(sF) % the position where the minimum is atained
%
%   [value,pos] = min(sF,'numLocal',5) % the 5 largest local minima
%
%   sF = min(sF, c) % minimum of a spherical functions and a constant
%   sF = min(sF1, sF2) % minimum of two spherical functions
%   sF = min(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the minimum of a multivariate function along dim
%   sF = min(sFmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S2Fun
%  sFmulti - a multivariate @S2Fun
%  c       - double
%
% Output
%  value - double
%  pos   - @vector3d
%  S2F   - @S2Fun
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @vector3d
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%

sF = sF.truncate;

% pointwise minimum of two spherical functions
if ( nargin > 1 ) && ( isa(varargin{1}, 'S2Fun') )
  f = @(v) min(sF.eval(v), varargin{1}.eval(v));
  value = S2FunHarmonic.quadrature(f);

% pointwise minimum of spherical harmonics
elseif ( nargin > 1 ) && ~isempty(varargin{1}) && ( isa(varargin{1}, 'double') )

  f = @(v) min(sF.eval(v), varargin{1});
  value = S2FunHarmonic.quadrature(f);

elseif (nargin > 1) && isempty(varargin{1}) % third input is dimension
  
  s = size(sF);
  if nargin < 2
    d = find(s ~= 1); % first non-singelton dimension
  else
    d = varargin{2};
  end
  f = @(v) min(reshape(sF.eval(v),[length(v),s]), [], d(1)+1);
  value = S2FunHarmonic.quadrature(f);

else % detect local or global minima

  % set  up initial search grid
  isAntipodal = sF.antipodal;
  if check_option(varargin, 'startingNodes')
  
    pos = get_option(varargin, 'startingNodes');  
    if pos.isOption('resolution')
      res0 = pos.resolution;
    else
      res0 = 5 * degree;
    end
  else

    assert(isscalar(sF),'Search for local and global extrema ist only implmented for scalar functions.')

    antipodalFlag = {'','antipodal'};

    res0 = get_option(varargin,'maxStepSize',5*degree) / 2;
    if isa(sF,'S2FunHarmonic')
      res0 = max(res0,1*degree / max(4,sF.bandwidth) *128);
    end

    if isa(sF,'S2FunHarmonicSym')
      sym =  sF.s;
      if isAntipodal, sym = sym.Laue; end
      sR = sym.fundamentalSector;
    else
      sR = {};
    end
    
    pos = equispacedS2Grid('resolution', res0, antipodalFlag{isAntipodal+1},sR);
    res0 = pos.resolution;
  end

  % evaluate function on grid
  pos = reshape(pos,[],1);
  value = eval(sF,pos);

  % take only local minima as starting points
  pos = pos(isLocalMinD(value,pos,res0,varargin{:}));

  % turn into Miller if needed
  if exist('sym','var') && isa(sym,'crystalSymmetry'), pos = Miller(pos, sym); end

  % perform local search
  [value, pos] = steepestDescent(sF, pos, varargin{:}, 'maxTravel',2*res0);
  
  % format output
  [value, I] = sort(value);
  if check_option(varargin, 'numLocal')
    n = get_option(varargin, 'numLocal');
    n = min(length(value), n);
    value = value(1:n);
  else
    n = 1;
    value = value(1);
  end
  pos = pos(I(1:n));

end

end
