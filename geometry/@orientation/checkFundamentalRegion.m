function ind = checkFundamentalRegion(ori,varargin)
% checks whether a orientation sits within the fundamental region
%
%% Input
%  ori - @orientation
%
%% Options
%  center - @quaternion / center of fundamental region
%
%% Output
%  ind    - indices of those orientations that are within the Fundamental region

% symmetrise
center = get_option(varargin,'center',idquaternion);
c_sym = ori.SS *  quaternion(center) * ori.CS;
omega = angle(c_sym * inverse(center));
[omega,c_sym] = selectMinbyRow(omega,c_sym);

% convert to rodrigues space
rq = Rodrigues(ori); clear ori;
rc_sym = Rodrigues(c_sym); 

% to remeber perpendicular planes for specimen symmetry case
oldD = vector3d;

% find rotation not part of the fundamental region
ind = true(size(rq));
for i = 2:numel(rc_sym)
  
  d = rc_sym(i)-rc_sym(1);
  if norm(d)<=1e-10 % find something that is orthogonal to rc_sym    
  
    if length(oldD)==0
      d = orth(rc_sym(1));
    elseif length(oldD) == 1
      d = cross(oldD,rc_sym(1));
      if norm(d)<1e-5, d = orth(oldD);end
    else
      continue
    end
    oldD = [oldD,d]; %#ok<AGROW>
    nd = 0;
  else
    nd = norm(d).^2 /2;
  end
  
  ind = ind & dot(rq-rc_sym(1),d) <= nd;
  
end

