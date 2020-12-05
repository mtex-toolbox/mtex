function str = alignment(cs)
% return alignment of the reference frame as string, e.g. x||a, y||b*


if ~cs.lattice.isEucledean
    
  abc = normalize(cs.axes);
  abcStar = normalize(cs.axesDual);
  [uabc,ind] = unique([abc,abcStar]);
  
  [y,x] = find(isappr(abs(dot_outer(uabc,[xvector,yvector,zvector])),1));
  
  abcLabel = {'a','b','c','a*','b*','c*'};
  abcLabel = abcLabel(ind);
  xyzLabel = {'X','Y','Z'};
  
  str = cell(1,length(x));
  for i = 1:length(x)
    str{i} = [xyzLabel{x(i)} '||' abcLabel{y(i)}];
  end
else
  str = {};
end
