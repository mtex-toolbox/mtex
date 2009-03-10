%%

cs = symmetry('m-3m');
ss = symmetry('-1');

odf2 = unimodalODF(idquaternion,cs,ss,'halfwidth',1.5*degree);

%%

q = modalorientation(odf);

%%
v = [];
r = linspace(0*degree,60*degree,20);
for i = 1:length(r)
  fprintf('.');
  %v(i,1) = volume(odf,q,r(i)); 
  v(i,2) = volume(odf2,idquaternion,r(i)); 
  v(i,1) = volume(uniformODF(cs,ss),idquaternion,r(i)); 
end
fprintf('\n');
%v(:,2) = length(cs)*(r - sin(r))./pi;

plot(r/degree,v);

%%
clear v;
cs = symmetry('m-3m');
ss = symmetry('mmm');
r = linspace(0,60*degree,10);
omega = linspace(0,45*degree,10);
for i = 1:length(r)
  for j = 1:length(omega)
    v(i,j) = volume(uniformODF(cs,ss),axis2quat(xvector,omega(j)),r(i)); disp(v(i,j))
  end
end

plot(r/degree,v);

%%

%r = linspace(0,100*degree,20);
%for i = 1:length(r)
%  v(i,1) = volume(odf,modalorientation(odf),r(i));
%  v(i,2) = volume(uniformODF(cs,ss),idquaternion,r(i)); 
%end

%plot(r/degree,v);
