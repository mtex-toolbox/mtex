function [v,iv,iu] = unique(v,varargin)
% disjoint list of vectors
%
% Syntax
%   u = unique(v) % find disjoint elements of the vector v
%   u = unique(v,'tolerance',0.01) % use tolerance 0.01
%   [u,iv,iu] = unique(v,varargin)] 
%    
%
% Input
%  v - @vector3d
%  tol - double (default 1e-7)
%
% Output
%  u - @vector3d
%  ir - index such that u = r(ir)
%  iv - index such that r = u(iv)
%
% Flags
%  stable      - prevent sorting
%  antipodal   - tread vectors as axes
%  noAntipodal - ignore antipodal symmetry
%  noSymmetry  - ignore crystal symmetry
%
% See also
% unique
%

% under a group two directions are the same when they are symmetrically
% equivalent, so the symmetrised sets are compared and not the directions
if hasSymmetry(v) && ~check_option(varargin,'noSymmetry')

  vSym = symmetrise(v,varargin{:});

  [~,~,iu] = unique(vSym,varargin{:},'noSymmetry');

  [~,iv,iu] = unique(min(reshape(iu,size(vSym)),[],1));

  v = v.subSet(iv);
  return
end

x = v.x(:);
y = v.y(:);
z = v.z(:);

if (check_option(varargin,'antipodal') || v.antipodal) && ~check_option(varargin,'noAntipodal')
  xyz = [x.^2,y.^2,z.^2,x.*y,x.*z,y.*z];  
else
  xyz = [x,y,z];  
end

tol = get_option(varargin,'tolerance',1e-6);

% in case it should not be sorted
if check_option(varargin,'stable')
  [~,iv,iu] = unique(round(xyz./tol/(tol+max(xyz(:)))),'rows','stable');
else
  [~,iv,iu] = uniquetol(xyz,tol,'ByRows',true,'DataScale',1);
end

% remove duplicated points
v.x = v.x(iv);
v.y = v.y(iv);
v.z = v.z(iv);
