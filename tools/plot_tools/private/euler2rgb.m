function c = euler2rgb(S3G,varargin)
% converts orientations to rgb values

% get reference orientation
q0 = get_option(varargin,'center',idquaternion);
S3G = inverse(q0) * S3G;

% restrict to fundamental region
q = getFundamentalRegion(S3G);

% convert to euler angles angles
[phi1,Phi,phi2] = quat2euler(q(:),'Bunge');

phi1 = mod(-phi1,pi/2) *2 ./ pi;
Phi = mod(-Phi,pi/2); Phi = Phi./max(Phi(:));
phi2 = mod(-phi2,pi/2)*2 ./ pi;

c = [phi1(:),Phi(:),phi2(:)];
