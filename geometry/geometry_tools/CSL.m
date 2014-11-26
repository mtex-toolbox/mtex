function  [mori,hkl,omega,sigma] = CSL(sigma,varargin)
% coincidence site lattice misorientations for cubic symmetry
%
% Syntax
%  q = CSL(sigma)
%
% Options
%  delta    - search radius around angle or axis
%  maxsigma - 
%
% Output 
%  o - @orientation
%

csl = generateCubicCSL(varargin{:});

if nargin > 0
  ndx = find( [csl.sigma] == sigma );
else
  ndx = 1:numel(csl);
end

cs = getClass(varargin,'symmetry',crystalSymmetry('cubic'));
mori = orientation(cs,cs);
hkl = zeros(0,3);
omega = []; sigma = [];

for k = ndx
  hkl(end+1,:) = csl(k).axis;
  omega(end+1) = csl(k).angle;
  sigma(end+1) = csl(k).sigma;
  mori(end+1) =  orientation('axis',vector3d(hkl(end,:)),'angle',omega(end),cs,cs);
end

mori = unique(mori);


end

function csl = generateCubicCSL(varargin)  % only cubic

csl = struct('sigma',{},'axis',{},'angle',{});

maxsigma = get_option(varargin,'maxsigma',60);

% heuristic
for u=0:5
  for v=0:5
    for w=0:5
      maxis = [u v w];
      if all(maxis==0), continue; end
        
      for m=1:10
          
        N = sum(mod([maxis m],2));
        
        if mod(N,2), alpha = 1; else alpha = N; end

        sigma = sum([maxis m].^2)/alpha;

        omega =  2*atan( sqrt( sum(maxis.^2) )/m );

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
