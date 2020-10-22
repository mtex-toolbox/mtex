clear all

rng(11)

rot = orientation.rand(1000);
SO3F = calcDensity(rot,'harmonic','bandwidth',64,'halfwidth',2.5*degree);
SO3F = SO3FunHarmonic(SO3F.components{1}.f_hat)

%lines from evalfft
H=64;
h = pi/(H+1);


% create random ori
ori=rotation.byEuler(rand*2*pi,34*h,rand*2*pi);

%lines from evalfft to get next gridpoint
abg = Euler(ori,'nfft');
abg= mod(mod(abg+[-pi/2,0,pi/2],2*pi)/h,2*H+2)
basic=round(abg);


% add ori at next gridpoint (for ori(2) abg == basic)
ori(2)=rotation.byEuler(basic*h-[-pi/2,0,pi/2],'ZYZ');



%%
tic
f0=eval(SO3F,ori)
toc


tic
f1 = SO3F.evalfft(ori,'nearest')'
toc


abs(f0-f1)

% ori(2) has the same value as ori(1) in evalfft, because they are rounded
% to the same nearest gridpoint.
% ori(2) is very close to this gridpoint, therefore it has the same
% functionvalue. ori(1) is a little bit away from this gridpoint

%%
% plot of SO3F with fix gamma
% the plot shows all points that are 'nearest' ori(2) for fixed gamma
[A,G]=meshgrid(basic(1)-0.5:0.1:basic(1)+0.5,basic(3)-0.5:0.1:basic(3)+0.5);
A=(A*h+pi/2)/degree;
G=(G*h-pi/2)/degree;
rot=rotation.byEuler(A*degree,basic(2)*h,G*degree,'ZYZ');
Z=eval(SO3F,rot);
s=surf(A,G,Z);
s.EdgeColor = 'none';
xlabel('alpha')
ylabel('gamma')
zlabel('value')
title('SO3F at grid for alpha and beta with fix beta')
colorbar

%plot ori(1) and ori(2)
hold on
abg = Euler(ori,'nfft')/degree;
plot3(abg(:,1),abg(:,3),f0', 'ro')

view(-221,32)
