function [pf_unique,pf_dublicated] = unique(pf)
% remove dublicated points in a polefigure


for ip = 1:numel(pf)
  
  [x,y,z] = double(pf(ip).r);
  tri = convhulln([x(:),y(:), z(:)]);
  
  [ndx] = unique(tri);
  
  pf_unique(ip) = copy(pf(ip),ndx);
  pf_dublicated(ip) = delete(pf(ip),ndx);
  
end


