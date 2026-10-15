function ind = fundamental_region(q,cs,ss)

if isempty(q), ind = []; return; end

c = {};

% eliminiate 3 fold symmetry axis of cubic symmetries
switch cs.LaueName
  
  case   {'m-3m','m-3'}
    
    c{end+1}.v = vector3d([1 1 1 1 -1 -1 -1 -1],[1 1 -1 -1 1 1 -1 -1],[1 -1 1 -1 1 -1 1 -1]);
    c{end}.h = sqrt(3)/3;
    
    if strcmp(cs.LaueName,'m-3m')
      c{end+1}.v = vector3d([1 -1 0 0 0 0],[0 0 1 -1 0 0],[0 0 0 0 1 -1]);
      c{end}.h = sqrt(2)-1;
    end
end

switch ss.LaueName
  case 'mmm'
   c{end+1}.v = vector3d([-1 0],[0 -1],[0 0]);
   c{end}.h = 0;
end 

% find rotation not part of the fundamental region
rodrigues = Rodrigues(q); clear q;
ind = false(length(rodrigues),1);
for i = 1:length(c)
  for j = 1:length(c{i}.v)
    p = dot(rodrigues,1/norm(c{i}.v(j)) * c{i}.v(j));
    ind = ind | (p(:)>c{i}.h);
  end
end
