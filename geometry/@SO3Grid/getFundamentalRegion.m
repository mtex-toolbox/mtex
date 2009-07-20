function [q,omega] = getFundamentalRegion(S3G,q_ref)
% projects orientations to a fundamental region
%
%% Input
%  S3G - @SO3Grid
%
%% Options
%  CENTER - reference orientation
%
%% Output
%  q     - @quaternion
%  omega - rotational angle
% 
% q_ref = get_option(varargin,'center',idquaternion);
% 
% q = symmetriceQuat(S3G(1).CS,[],quaternion(S3G));
% omega = 2*acos(abs(dot(q,q_ref)));
% 
% [omega,q] = selectMinbyRow(omega,q);

if nargin == 1, q_ref = idquaternion;end
if length(S3G) > 1 || size(S3G.Grid,2) > 1
  q = quaternion(S3G);
else
  q = S3G.Grid;
end

% may be we can skip something
omega = abs(dot(q,q_ref));
ind = omega < cos(20*degree);

if ~any(ind), 
  omega = 2*acos(max(1,omega));
  return;
end

% 
qSym = quaternion(S3G(1).CS);

% compuate all distances to the fundamental regions
omegaSym = dot_outer(q_ref .* qSym,q);

% find fundamental region
[omega,idy] = selectMaxbyColumn2(omegaSym);

% project to fundamental region
qSym = reshape(inverse(qSym),1,[]);
q = q .* qSym(idy);

% compute angle
omega = 2*acos(min(1,omega));


function [maxA,idy] = selectMaxbyColumn2(A)
% find maximum in each column

% maxA
maxA = max(A,[],1);

% find min values
ind = bsxfun(@ne,A,maxA);
%A ~= repmat(maxA,size(A,1),1);

% find index 
idy = sum(cumprod(double(ind),1),1)+1;
 
