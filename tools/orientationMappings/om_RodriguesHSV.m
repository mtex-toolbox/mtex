function [c,options] = om_RodriguesHSV(o,varargin)
% converts orientations to rgb values

% 
o = project2FundamentalRegion(o);

% 
v = Rodrigues(o);

cs = get(o,'cs');

switch Laue(cs)
  
  case '-1'
    a = abs(angle(o)) ./ pi;
    
  otherwise
    
    h = getFundamentalRegionRodriguez(cs);
    h = h ./ norm(h).^2;
    
    a = max(abs(dot_outer(h,v)));
            
end

%% compute directional dependend color

h = v./norm(v);

constraints = [yvector,zvector,zvector];

center = sph2vec(pi/4,pi/4);

[theta,rho] = polar(v);


[sh,pm] = project2FundamentalRegion(h,{symmetry(3)});
%sh = v(:);


%% compute angle
rx = center - zvector; rx = rx ./ norm(rx);
ry = cross(center,rx); ry = ry ./ norm(ry);
dv = (center - sh); dv = dv ./ norm(dv);
omega = mod(atan2(dot(rx,dv),dot(ry,dv))-pi/2,2*pi);
omega(isnan(omega)) = 0;
omega = omega(:);


%% compute saturation

% center
cc = cross(sh,center);
cc = cc ./ norm(cc);

% compute saturation
dh = zeros([size(sh),length(constraints)]);
for i = 1:length(constraints)
    
  % boundary points
  bc = cross(cc,constraints(i));
  bc = bc ./ norm(bc);

  % compute distances
  dh(:,:,i) = angle(-sh,bc)./angle(-center,bc);
  dh(isnan(dh)) = 1;
end
dh = min(dh,[],3);

dh(imag(dh) ~=0 ) = 0;
dh = dh(:);

ind = xor(rho>=0,theta<=pi/2);
%ind = rho>=0;
%ind = true(size(rho));

% black center
dh(ind) = (1-dh(ind))./2;
% white center
dh(~ind) = 0.5+dh(~ind)./2;

L = (dh - 0.5) .* a(:) + 0.5;

S = a(:) .* (1-abs(2*dh-1)) ./ (1-abs(2*L-1));

%% compute colors

[h,s,v] = hsl2hsv(omega./2./pi,S,L);
c = hsv2rgb(h,s,v);
options = varargin;

return

%%

v = S2Grid('plot');
o = orientation('axis',v,'angle',0.51*pi,symmetry(1));

c = rodrigues2rgb(o);
c = reshape(c,[size(v),3]);

surf(v,c)

%%

ebsdColorbar(symmetry(1),'colorcoding','RodriguesHSV','sections',12,'resolution',1*degree,'north')
%ebsdColorbar(symmetry(3),'colorcoding','RodriguesHSV','sections',12,'resolution',1*degree,'south')

%%

ebsdColorbar(symmetry('-1'),'colorcoding','RodriguesHSV','sections',12,'phi1','projection','plain')
