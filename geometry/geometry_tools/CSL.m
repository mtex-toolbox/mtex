function q = CSL(sigma,varargin)
% return orientation of coincidence site lattice for cubic symmetry
%
%% Syntax
%  q = CSL(sigma)
%  q = CSL(angle)   - angle in radians of csl rotation
%  q = CSL([u v w]) - axis of csl rotation
%
%% Options
%  delta    - search radius around angle or axis
%  maxsigma - 
%
%% Output 
%  o - @orientation
%

csl = generateCubicCSL(varargin{:});

if isa(sigma,'vector3d') || numel(sigma) == 3
  [qr csl] = findbyAxis(csl,sigma,varargin{:});
elseif sigma > 100*degree
  [qr csl] = findbySigma(csl,sigma);
elseif numel(sigma) == 1
  [qr csl] = findbyAngle(csl,sigma,varargin{:});
end

if nargout == 0
  listCSL(csl);
else
  q = orientation(qr,symmetry('cubic'));
end


function csl = generateCubicCSL(varargin)  % only cubic

csl = struct('sigma',[],'axis',[],'angle',[]);

maxsigma = get_option(varargin,'maxsigma',60);

% heuristic
for u=0:5
  for v=0:5
    for w=0:5
      maxis = [u v w];
      if sum(maxis) ~= 0
        for m=1:10
          
          N = sum(mod([maxis m],2));

          if mod(N,2)
            alpha = 1;
          else
            alpha = N;
          end

          sigma = sum([maxis m].^2)/alpha;

          omega =  2*atan( sqrt( sum(maxis.^2) )/m );

          if omega < 63*degree && sigma < maxsigma
            n = numel(csl)+1;
            if isempty(csl(1).sigma), n=1; end

            csl(n).angle = omega;
            csl(n).axis = maxis;
            csl(n).sigma = sigma;

          end
        end
        
      end
    end
  end
end



function [q csl] = findbySigma(csl,sigma)

sigmas = [csl.sigma];

ndx = find( sigmas == sigma );

q = quaternion;
for k = ndx
  q(end+1) =  axis2quat(vector3d(csl(k).axis),csl(k).angle);
end

csl = csl(ndx);


function [q csl] = findbyAngle(csl,omega,varargin)

angles = [csl.angle];
delta = get_option(varargin,'delta',1*degree);

ndx = find( abs(angles-omega) < delta );

[a ndx2] = sort([csl(ndx).sigma]);

q = quaternion;
for k=ndx(ndx2)
  q(end+1) =  axis2quat(vector3d(csl(k).axis),csl(k).angle);
end

csl = csl(ndx(ndx2));


function [q csl] = findbyAxis(csl,saxis,varargin)

saxis = vector3d(saxis);
delta = get_option(varargin,'delta',.1*degree);

axess = vector3d(vertcat(csl.axis)');



% fprintf('CSL by axis: %s with delta %5.2f\n',char(saxis), delta/degree);

ndx = find( angle(axess,saxis) < delta );

[a ndx2] = sort([csl(ndx).sigma]);

q = quaternion;
for k=ndx(ndx2)
  q(end+1) =  axis2quat(vector3d(csl(k).axis),csl(k).angle);
end

csl = csl(ndx(ndx2));


function listCSL(csl)

ndx = 1:numel(csl);
[a ind] = sort([csl.angle]);
ndx = ndx(ind);
[a ind] = sort([csl(ndx).sigma]);
ndx = ndx(ind);

for k = ndx
  cs = csl(k); 
  fprintf(' sigma: %2d  | %5.3f°/[%d%d%d]  \n', cs.sigma, cs.angle/degree,cs.axis);
end
