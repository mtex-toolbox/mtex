%%

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('1');

odf = unimodalODF(quaternion.id,cs,ss,'halfwidth',1.5*degree);

%%

q = calcModes(odf)

%%
v = [];
r = linspace(1*degree,10*degree,10);
for i = 1:length(r)
  fprintf('.');
  v(i,1) = volume(odf,q,r(i)); 
  v(i,2) = volume(odf,quaternion.id,r(i)); 
  %v(i,1) = volume(uniformODF(cs,ss),quaternion.id,r(i)); 
end
fprintf('\n');
%v(:,2) = length(cs)*(r - sin(r))./pi;

plot(r/degree,v);

%%
clear v;
cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('mmm');
r = linspace(0*degree,60*degree,20);
omega = linspace(0,45*degree,4);
for i = 1:length(r)
  for j = 1:length(omega)
    %disp(r(i));
    %tic
    v(i,j,1) = volume(uniformODF(cs,ss),axis2quat(vector3d(1,1,1),omega(j)),r(i));
    %toc
    %tic
    %v(i,j,2) = volume(uniformODF(cs,ss),axis2quat(xvector,omega(j)),r(i),'local');
    %toc
    fprintf('.');
  end
end
fprintf('\n');
plot(r/degree,reshape(v,size(v,1),[]));

%%

%r = linspace(0,100*degree,20);
%for i = 1:length(r)
%  v(i,1) = volume(odf,calcModes(odf),r(i));
%  v(i,2) = volume(uniformODF(cs,ss),quaternion.id,r(i)); 
%end

%plot(r/degree,v);

%%
cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('mmm');
S3G = SO3Grid(1*degree,cs,ss);
r = plotS2Grid('resolution',10*degree,'hemisphere','upper','maxrho',90*degree,'RESTRICT2MINMAX');
rv = vector3d(r);
d1 = zeros(size(rv));
d2 = zeros(size(rv));
for i = 1:length(rv)
  q = axis2quat(rv(i),20*degree);
  d1(i) = length(find(dot_outer(S3G,q,'epsilon',20*degree)));
  d2(i) = volume(uniformODF(cs,ss),q,15*degree);
  fprintf('.');
end
fprintf('\n');
figure(1)
plot(r,d1./d1(1),'smooth')
figure(2)
plot(r,d2./d2(1),'smooth')
colorbar
%%
