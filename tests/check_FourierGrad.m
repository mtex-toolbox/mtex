function check_FourierGrad

S = mtexdata('dubna');
pf = S.pf;
odf = calcODF(pf,'zeroRange');
fodf = FourierODF(odf);

ori = orientation.rand(1000,pf.CS);
g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)./norm(g1)) < 1e-2
  disp(' Fourier gradient test passed');
else
  disp(' Fourier gradient test failed');
end

return


%% test 1 - check f_theta
cs = crystalSymmetry('1');
odf = fibreODF(Miller(0,0,1,cs),vector3d.Z,'halfwidth',40*degree);
fodf = FourierODF(odf);

omega = linspace(-179,179) * degree;
ori = rotation.byAxisAngle(vector3d(0,1,0),omega);

g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-3, disp(' Test 1 passed'); end

%% test 2

ori = rotation.byAxisAngle(vector3d(1,2,0)s,omega);

g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-3, disp(' Test 2 passed'); end

%% test 3 - check last line in grad composition

ori = rotation.byAxisAngle(vector3d(1,2,3),omega);

g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-2
  disp(' Test 3 passed');
else
  disp(' Test 3 failed');
end

%% test 4 - final f_theta test

ori = orientation.rand(100,cs);
g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-2
  disp(' Test 4 passed');
else
  disp(' Test 4 failed');
end

%% test 5 - f_phi1 test

odf = fibreODF(Miller(0,1,0,cs),vector3d.Y,'halfwidth',40*degree);
fodf = FourierODF(odf);

ori = orientation.byEuler(omega,89.9999*degree,0*degree,cs,'ABG');

%odf.grad(rot)
g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-2
  disp(' f_phi1 test passed');
else
  disp(' f_phi1 test failed');
end


%% test 6 - f_phi1 test

odf = fibreODF(Miller(0,1,0,cs),vector3d.Y,'halfwidth',40*degree);
fodf = FourierODF(odf);

ori = orientation.byEuler(0,89.9999*degree,omega,cs,'ABG');

%odf.grad(rot)
g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-2
  disp(' f_phi2 test passed');
else
  disp(' f_phi2 test failed');
end





%% test 5 - f_phi1 + f_phi_2 test

odf = fibreODF(Miller(0,1,0,cs),vector3d.Y,'halfwidth',40*degree);
fodf = FourierODF(odf);

ori = orientation.byAxisAngle(vector3d(0,1,100),omega);

%odf.grad(rot)
g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-2
  disp(' Test 6 passed');
else
  disp(' Test 6 failed');
end

%% test 6 - f_phi1 - f_phi_2 test

odf = fibreODF(Miller(0,1,0,cs),vector3d.Y,'halfwidth',40*degree);
fodf = FourierODF(odf);

ori = orientation.byAxisAngle(vector3d(0,1,100),omega);

%odf.grad(rot)
g1 = fodf.grad(ori(:),'check','delta',0.1*degree);
g2 = fodf.grad(ori(:));

if max(norm(g1-g2)) < 1e-2
  disp(' Test 6 passed');
else
  disp(' Test 6 failed');
end

%%
function testing

cs = crystalSymmetry('1');
%ref = orientation.id(cs);
ref = orientation.rand(cs);
odf = unimodalODF(ref,'halfwidth',40*degree);

fodf = FourierODF(odf)

omega = linspace(0,40)*degree;
%omega = 5*degree;
rot = ref*rotation(vector3d(1,1,1),omega)

g2 = fodf.grad(rot,'check','delta',0.05*degree)
g3 = odf.grad(rot)
g1 = fodf.grad(rot)

fodf.eval(rot)
odf.eval(rot)

%plot(norm(odf.grad(rot))

end


%%
function test2

cs = crystalSymmetry('1');
odf = fibreODF(Miller(0,1,0,cs),vector3d.Y,'halfwidth',40*degree);
fodf = FourierODF(odf)

omega = 50*degree;
%omega = linspace(0,179)*degree;
%ori = orientation('axis',vector3d(0,1,100),'angle',omega,cs);
%ori = orientation.byEuler(0*degree,0.01*degree,omega,cs,'ABG');

% f_phi1 test with cos(Phi) == 0 --> ok
ori = orientation.byEuler(omega,89.9999*degree,30*degree,cs,'ABG')

%%
% f_phi2 test with cos(Phi) == 1

omega = 80*degree
%omega = linspace(0,89)*degree;


odf = fibreODF(Miller(0,1,0,cs),vector3d.Z,'halfwidth',40*degree);
fodf = FourierODF(odf)

%ori = orientation.byEuler(0*degree,omega,[ 90]*degree,cs,'ABG');

%ori = orientation.rand(100,cs);

ori = orientation.byEuler(0*degree,90*degree,45*degree,cs,'ABG');
%ori = orientation.byEuler(10*degree,80*degree,[ 90]*degree,cs,'ABG');

g2 = fodf.grad(ori(:))
g1 = odf.grad(ori(:))


d_Phi(odf,ori)
d_phi1(odf,ori)
d_phi2(odf,ori)


%%

fhat1 = zeros(3);% fhat1([4 6]) = [1 -1]*1i;
fhat1 = zeros(3); %fhat1(9) = 1;
fhat2 = zeros(5); %fhat2([6,8,10]) = 1;
fhat2 = zeros(5); fhat2(4) = 1;
fhat3 = zeros(7); %fhat3([22 24 26 28]) = [1 1 -1 -1]*1i;
odf2 = FourierODF([1;fhat1(:);fhat2(:);fhat3(:)],cs);


[g1,d1,d2,d3] = odf2.components{1}.grad(ori3);
g1
g2 = odf2.grad(ori3,'check')

[d_phi1(odf2,ori3),d_Phi(odf2,ori3),d_phi2(odf2,ori3);...
  d1,d2,d3]

%%

%plot([norm(g1-g2)])
plot([g1.z , g2.z]) % x anfangs ok dann zu schnell negativ
plot([g1.y,g2.y])   % y - sollte konstant 0 sein
plot([g2.z,g1.z])  % z - faktor 4 zu groß
fodf.eval(ori)
odf.eval(ori)

%plot(norm(odf.grad(rot))

end

function test1

cs = crystalSymmetry('1');
odf = fibreODF(Miller(0,0,1,cs),vector3d.Z,'halfwidth',40*degree);
fodf = FourierODF(odf)

omega = 55*degree
%omega = linspace(-179,179) * degree;
ori = rotation.byAxisAngle(vector3d(-1,1,3),omega)
%ori = orientation.rand(cs);

%odf.grad(rot)
g1 = fodf.grad(ori(:),'check','delta',0.1*degree)
g2 = fodf.grad(ori(:))

plot([g1.y,g2.y])

end


end
