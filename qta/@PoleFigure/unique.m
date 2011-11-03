function pf = unique(pf)
% remove dublicated points in a polefigure

for ip = 1:numel(pf)
      
  [r,ndx] = unique(pf(ip).r); %#ok<ASGLU>
    
  pf(ip) = copy(pf(ip),ndx);
    
end
