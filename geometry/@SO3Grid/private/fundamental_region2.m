function ind = fundamental_region2(q,center,cs,ss)
%
%% Input
%  q      - @quaternion to project
%  center - center of fundamental region
%  cs, ss - crystal and specimen @symmetry
%
%% Output
%  ind    -

% symmetrise
c_sym = ss *  center * cs;
omega = angle(c_sym * inv(center));
[omega,c_sym] = selectMinbyRow(omega,c_sym);

% convert to rodrigues space
rq = Rodrigues(q); clear q;
rc_sym = Rodrigues(c_sym); 

% to remeber perpendicular planes for specimen symmetry case
oldD = vector3d;

% find rotation not part of the fundamental region
ind = true(size(rq));
for i = 2:length(rc_sym)
  
  d = rc_sym(i)-rc_sym(1);
  if norm(d)<=1e-10 % find something that is orthogonal to rc_sym    
  
    if isempty(oldD)
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

