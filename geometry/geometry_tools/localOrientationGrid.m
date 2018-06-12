function ori = localOrientationGrid(CS,SS,maxAngle,varargin)
% define a equispaced grid localized to a center orientation
%
% Input
%  CS       - @symmetry
%  SS       - @symmetry
%  maxAngle - 
%
% Output
%
%  ori - @orientation
%

% get resolution
if check_option(varargin,'points')
  res = maxAngle/(get_option(varargin,'points')/4)^(1/3);
else
  res = get_option(varargin,'resolution',5*degree);
end

% construct an equispaced axes / angle grid
rotAngle = res/2:res:maxAngle;
qId = quaternion();
for i = 1:length(rotAngle)
  
  dres = acos(max((cos(res/2)-cos(rotAngle(i)/2)^2)/...
    (sin(rotAngle(i)/2)^2),-1));  
  axes = equispacedS2Grid('resolution',dres);
  
  qId = [qId,axis2quat(axes,rotAngle(i))]; %#ok<AGROW>
end

% project center to fundamental region 
% TODO: call project2FundamentalRegion ???
center = quaternion(get_option(varargin,'center',rotation.id));
sym_center = symmetrise(center,CS.properGroup,SS.properGroup);
[~,ind] = min(angle(sym_center),[],1);
center = sym_center(ind);

% restrict to fundamental region
% we do only have to respect specimen symmetr since we assume maxangle to
% be sufficiently small
q = quaternion;
for i = 1:length(center)
  cq = center(i) * qId(:);
  if length(SS) > 1
    ind = fundamental_region2(cq,center(i),CS,SS);
    cq = cq(ind);
  end
  q = [q;cq(:)]; %#ok<AGROW>
end

ori = orientation(q,CS,SS);

end

function ind = fundamental_region2(q,center,cs,ss)
%
% Input
%  q      - @quaternion to project
%  center - center of fundamental region
%  cs, ss - crystal and specimen @symmetry
%
% Output
%  ind    -

% symmetrise
c_sym = ss *  center * cs;
omega = angle(c_sym * inv(center)); %#ok<MINV>
%[~,i] = min(omega,[],2);
%c_sym = c_sym(sub2ind(sie(c_sym,i));
[~,c_sym] = selectMinbyRow(omega,c_sym);

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


end
