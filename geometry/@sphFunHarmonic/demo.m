function demo

%f = @(v) smiley(v);
%f = @(v) exp(v.x+v.y+v.z)+50*(v.y-cos(pi/3)).^3.*((v.y-cos(pi/3)).^3>0);
f = @(v) sin(8*v.rho).*sin(8*v.theta);

sF = sphFunHarmonic.quadrature(f, 'm', 200);
sVF = grad(sF);
v = min(sF);

figure(1);
clf;
plot3d(sF);
hold on;
quiver3(sVF);
scatter3d(v, ones(3, length(v)));
hold off;

%figure(2);
%plot(sVF);

end

function f = smiley(v)%{{{

% Radial test function: quadratic spline
f_r0=@(z,h)bsxfun(@gt,z,h).*bsxfun(@times,bsxfun(@minus,z,h).^2,1./(1-h).^2);
g_r = @(t,h) bsxfun(@times,bsxfun(@lt,t.^2,1-h.^2),bsxfun(@times,(bsxfun(@times,-3*h,sqrt(1-bsxfun(@plus,t.^2,h.^2)))...
    +bsxfun(@times,bsxfun(@plus,1-t.^2,2*h.^2),acos(bsxfun(@times,h,1./sqrt(1-t.^2))))),1./(1-h).^2)/pi);

x_0 = [0,0; 0.5,2.2; 1.3,2.2; 0.9,1.5; 0.6,1.6; 1.2,1.6; ];
h_0 = [0.6; 0.98; 0.98; 0.9; 0.9; 0.9; ];
c_0 = [0.6; -0.7; -0.7; 0.4; 0.4; 0.4; ];

f_r=@(z,h)f_r0(z,h)+f_r0(-z,h); % f has to be even
f2=@(ph,th)sum(bsxfun(@times,c_0,f_r(bsxfun(@times,cos(x_0(:,2)),cos(th)) ...
    +bsxfun(@times,sin(x_0(:,2)),sin(th)).*cos(bsxfun(@minus,ph,x_0(:,1))),h_0)),1);
g=@(ph,th)sum(bsxfun(@times,c_0,g_r(bsxfun(@times,cos(x_0(:,2)),cos(th)) ...
    +bsxfun(@times,sin(x_0(:,2)),sin(th)).*cos(bsxfun(@minus,ph,x_0(:,1))),h_0)),1);

alpha1 = pi;
alpha2 = 0;
rotate = @(v) vector3d([cos(alpha1) -sin(alpha1) 0; sin(alpha1) cos(alpha1) 0; 0 0 1]*[cos(alpha2) 0 -sin(alpha2); 0 1 0; sin(alpha2) 0 cos(alpha2)]*(v.xyz).').';
fh2 = @(v) f2(v.rho', v.theta')';
fh = @(v) fh2(rotate(v));

f = fh(v);

end%}}}
