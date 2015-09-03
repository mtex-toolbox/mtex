function oR = cleanUp(oR)


% testing:
% cs = crystalSymmetry('222');
% oR = cs.fundamentalRegion;

% we need to restrict to the relevant normals
% this works nice if rotations about 180 degree are present
is180 = abs(oR.N.angle)>pi - 1e-3;
if ~any(is180)
  
  % then the normals should be inside itself
  Nq = unique(oR.N); 
  Nq = Nq.subSet(oR.checkInside(-reciprocal(Nq)));
  oR.N = Nq;  
  
else % otherwise the condition seems to strict 

  % we consider first the case without 180 degree rotations
  oRfull = oR;
  oRfull.N(is180) = [];
  oRfull = oRfull.cleanUp;
  
  ind = oR.checkInside(oRfull.V);
  
  inside = cellfun(@(x) any(ind(x)), oRfull.F);
  
  Nq = [oRfull.N(inside),oR.N(is180)];
  oR.N = Nq;
end


nqa = unique(Nq.axis,'antipodal');

if isempty(nqa)
  
  oR.V = quaternion;
  oR.F = {};
  return
  
elseif length(nqa)==1
  
  v = perp(nqa);
  rot = rotation('axis',nqa,'angle',(0:90:270)*degree);
  oR.V = rotation('axis',rot*v,'angle',pi*ones(4,1));
  oR.F = repcell(1:4,size(oR.N));
  
  return
end


% compute vertices

% set up faces
for j = 1:length(Nq)
  
  Nqj = Nq(j);
  oNq = Nq; oNq(j) = [];
  oNq(abs(dot(oNq.axis,Nqj.axis))>1-1e-6) = [];
    
  % find closest other normal
  [~,j0] = min(angle(Nqj,oNq) + angle(Nqj.axis,oNq.axis));
  
  % rotate axis such that current face is z-direction
  % and closest plane
  aNq = oNq.axis;
  aNq0 = aNq(j0);
  aNqj = Nqj.axis;
  aNq0 = aNq0 - dot(aNq0,aNqj) * aNqj;
  rot = rotation('map',aNqj,zvector,aNq0,xvector);  
  aNq = rot * aNq; % the rotated axes
  
  % order the other normals according to
  % 1. angle to aNq0
  % 2. angle to Nqj
  [~,order] = sort(100*mod(aNq.rho+1e-5,2*pi) + aNq.theta);
  order(end+1) = order(1); %#ok<AGROW>
  
  % the first edge
  e = order(1);
  % go through all potential edges and compute vertices
  V{j} = quaternion;
  for i = 2:length(order)
    
    % if axis is in the same direction -> skip
    if isnull(aNq(order(i)).rho - aNq(e).rho), continue; end
    
    % is axis is inline whith Nqj -> skip
    %if abs(dot(aNq(order(i)),zvector))>1-1e-6, continue; end
    
    % compute vertice
    %a = Nqj; a = inv(a) * rotation('axis',a.axis,'angle',pi);
    %b = oNq(e); b = inv(b) * rotation('axis',b.axis,'angle',pi);
    %c = oNq(order(i)); c = inv(c) * rotation('axis',c.axis,'angle',pi);
    %v = cross(a,b,c);
    v = cross(Nqj,oNq(e),oNq(order(i)));
    v = v ./ norm(v);
    if abs(angle(v * Nqj))<1e-5 , continue; end
    
    % check vertex is inside
    if ~oR.checkInside(v), continue; end
    
    % if we have found a vertice - store it
    V{j}(end+1) = v;
    e = order(i);
    
  end
end

% make a unique list of vertices
sV = cellfun(@length,V);
[oR.V,~,iV] = unique([V{:}]);
F = 1:sum(sV);
F = mat2cell(F,1,sV);
oR.F = cellfun(@(x) iV(x),F,'uniformOutput',false);

end

function q = reciprocal(q)

q = q .* rotation('axis',-q.axis,'angle',pi);

end
