function str = alignment(cs)
% get alignment of the reference frame

    
if any(strcmp(cs.lattice,{'triclinic','monoclinic','trigonal','hexagonal'}))
    
  abc = normalize(cs.axes);
  abcStar = normalize(cs.axesDual);
  [uabc,ind] = unique([abc,abcStar]);
  
  [y,x] = find(isappr(dot_outer(uabc,[xvector,yvector,zvector]),1));
  
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
