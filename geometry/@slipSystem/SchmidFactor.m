function SF = SchmidFactor(sS,sigma,varargin)
% compute the Schmid factor 
%
% Syntax
%
%   SFfun = SchmidFactor(sS) % returns spherical function
%   SF = SchmidFactor(sS,v)
%   SF = SchmidFactor(sS,sigma)
%   SF = SchmidFactor(sS,sigma,'relative')
%
% Input
%  sS - list of @slipSystem
%  v  - @vector3d list of tension direction
%  sigma - @stressTensor
%
% Output
%  SFfun - size(sS) x 1 list of @S2FunHarmonic
%  SF - size(sS) x size(sigma) matrix of Schmid factors
%
% Description
% The slip systems and the stress state have to be given with respect to
% the same reference frame - either both in crystal coordinates, i.e.
% Miller indexed slip systems and |inv(ori) * sigma|, or both in specimen
% coordinates, i.e. |ori * sS| and a stress state as measured. Mixing the
% two is warned about as |MTEX:frameMismatch|. A tension direction that
% does not state a reference frame at all is taken at face value and never
% warned about.
%
% See also
% slipSystem/SchmidTensor stressTensor
%

b = sS.b.normalize; %#ok<*PROPLC>
n = sS.n.normalize;

% compute the relative Schmid factor by dividing by the critical resolved
% shear stress for every slip system
if check_option(varargin,'relative')
   b = b./ sS.CRSS;
end

% Schmid factor with respect to a tension direction
if nargin == 1 || (isnumeric(sigma) && isempty(sigma))
  
  % the quadrature nodes are frame free, hence checkFrame stays silent -
  % they are directions of whatever frame sS is given in
  SF = S2FunHarmonic.quadrature(@(v) sS.SchmidFactor(v,varargin{:}),...
    'bandwidth',4,sS.CS);

elseif isa(sigma,'vector3d')

  checkFrame(n,sigma,'tension direction');

  r = sigma.normalize;
  SF = dot_outer(r,b,'noSymmetry') .* dot_outer(r,n,'noSymmetry');

% Schmid factor with respect to a stress tensor
elseif isa(sigma,'stressTensor')

  checkFrame(n,sigma,'stress tensor');

  % normalize the stress tensor
  % such that the resulting Schmid factor is always between [0, 0.5]
  EV = eig(sigma);
  sigma = sigma ./ reshape(EV(3,:)-EV(1,:),size(sigma));
  
  if isscalar(sigma)
    SF = EinsteinSum(sigma,[-1,-2],n,-1,b,-2);
    SF = reshape(SF,size(sS));
  else
    SF = zeros(length(sigma),length(b));
  
    for i = 1:length(sS.b)
      SF(:,i) = EinsteinSum(sigma,[-1,-2],n(i),-1,b(i),-2);
    end
  end
    
else
  
  error('Second argument should be either vector3d or stressTensor.')

end
end

% --------------------------------------------------------------------

function checkFrame(n,ref,refName)
% warn if the slip systems and the stress state are given in different
% reference frames
%
% Slip systems are in crystal coordinates exactly if they are Miller
% indexed - the same convention slipSystem/get.CS follows - and in specimen
% coordinates otherwise, since rotating them (ori * sS) drops the Miller
% index. The frame decides, never the symmetry: a rotated tensor carries
% only the frame of the orientation (ADR 0003).

% a Miller index resolves its frame from its symmetry, a tensor from its
% own frame or its reference system, a vector3d only if it was given one
refFrame = ref.frame;

% a frame free direction states nothing, so take it at face value
if isempty(refFrame), return; end

if isa(n,'Miller') % slip systems in crystal coordinates
  isMismatch = ~isa(refFrame,'crystalFrame') || ~isAligned(refFrame,n.CS.frame);
else % slip systems in specimen coordinates
  isMismatch = isa(refFrame,'crystalFrame');
end

if isMismatch
  warning('MTEX:frameMismatch',...
    ['The reference frame of the ' refName ' and the slip systems do not match!']);
end

end
