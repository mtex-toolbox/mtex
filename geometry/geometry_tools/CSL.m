function  [mori,hkl,omega,sigma] = CSL(sigma,CS,varargin)
% coincidence site lattice misorientations for cubic symmetry
%
% Syntax
%   q = CSL(sigma,CS)
%
% Input
%  sigma - order of coincidence site lattice misorientation
%  CS - @crystalSymmetry
%
% Options
%  delta    - search radius around angle or axis
%  maxsigma - 
%
% Output 
%  o - @orientation
%

if nargin < 2 || ~isa(CS,'crystalSymmetry')
  error('Starting with MTEX 4.2 the second argument to CSL should be crystal symmetry.')
end

% we generate first all CSL misorientations up to sigma = 60
csl = generateCubicCSL(varargin{:});
% and then select those we are interested in
ndx = find( ismember([csl.sigma],sigma));

mori = orientation(CS,CS);
hkl = zeros(0,3);
omega = []; sigma = [];

for k = ndx
  hkl(end+1,:) = csl(k).axis;
  omega(end+1) = csl(k).angle;
  sigma(end+1) = csl(k).sigma;
  mori(end+1) = orientation.byAxisAngle(vector3d(hkl(end,:)),omega(end),CS,CS);
end

[mori,id] = unique(mori);
sigma = sigma(id);


end

function csl = generateCubicCSL(varargin)  % only cubic

csl = struct('sigma',{},'axis',{},'angle',{});

maxsigma = get_option(varargin,'maxsigma',60);

% heuristic
for u=0:5
  for v=0:5
    for w=0:5
      maxis = [u v w];
      %if all(maxis==0), continue; end
      
      % make sure u,v,w have no common divisor
      if gcd(u,gcd(v,w))~=1, continue; end
        
      for m=1:10
          
        N = sum(mod([maxis m],2));
        
        if mod(N,2)
          alpha = 1; 
        else
          alpha = N; 
        end
        
        % compute the energie
        sigma = sum([maxis m].^2)/alpha;

        % compute rotational angle
        omega =  2*atan( sqrt( sum(maxis.^2) )/m );

        % store values
        if omega < 63*degree && sigma < maxsigma          
          csl(end+1).angle = omega;
          csl(end).axis = maxis;
          csl(end).sigma = sigma;
        end
      end
    end
  end
end

end
