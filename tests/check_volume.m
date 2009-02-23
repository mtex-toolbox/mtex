%%

cs = symmetry('m-3m');
ss = symmetry('mmm');

odf = unimodalODF(idquaternion,cs,ss,'halfwidth',5*degree);

r = linspace(0,60*degree,20);
for i = 1:length(r)
  v(i,1) = volume(odf,idquaternion,r(i)); disp(v(i))
  v(i,2) = volume(uniformODF(cs,ss),idquaternion,r(i)); disp(v(i))
end

v(:,3) = length(cs)*(r - sin(r))./pi;

plot(r/degree,v);

%%



%r = linspace(0,100*degree,20);
%for i = 1:length(r)
%  v(i,1) = volume(odf,modalorientation(odf),r(i));
%  v(i,2) = volume(uniformODF(cs,ss),idquaternion,r(i)); 
%end

%plot(r/degree,v);
