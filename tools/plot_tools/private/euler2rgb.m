function c = euler2rgb(o,varargin)
% converts orientations to rgb values

[maxphi1,maxPhi,maxphi2] = getFundamentalRegion(get(o,'CS'),get(o,'SS'),varargin{:});


% get reference orientation
if check_option(varargin,'center')
  q0 = get_option(varargin,'center',idquaternion);

  % restrict to fundamental region
  o = project2FundamentalRegion(o,q0);
end

% convert to euler angles angles
[phi1,Phi,phi2] = Euler(o,'Bunge');

maxphi1 = min(maxphi1,max(phi1(:)) - min(phi1(:)));
maxPhi = min(maxPhi,max(Phi(:)) - min(Phi(:)));
maxphi2 = min(maxphi2,max(phi2(:)) - min(phi2(:)));

phi1 = mod(phi1,maxphi1) ./ maxphi1;
Phi = mod(Phi,maxPhi) ./ maxPhi;
phi2 = mod(phi2,maxphi2) ./ maxphi2;

c = [phi1(:),Phi(:),phi2(:)];
