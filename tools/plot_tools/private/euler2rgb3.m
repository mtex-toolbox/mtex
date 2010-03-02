function c = euler2rgb3(S3G,varargin)
% converts orientations to rgb values

% get reference orientation
q0 = get_option(varargin,'center',idquaternion);
S3G = inverse(q0) * S3G;

[max_phi1 max_Phi max_phi2] = getFundamentalRegion(get(S3G,'CS'),get(S3G,'SS'));

% restrict to fundamental region
o = project2FundamentalRegion(S3G);

% convert to euler angles angles
[phi1,Phi,phi2] = Euler(o(:),'BUNGE');

c1 = max(abs(phi1))-mod( abs(phi1), max_phi1);
c2 = max(Phi)-mod( Phi, max_Phi); 
c3 = mod( phi2+eps-max_phi2*2,max_phi2 ); 
c =  [c1(:),c2(:),c3(:)];
 
c = c./repmat(max(c),length(c),1);
 
