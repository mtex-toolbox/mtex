function C = boundarycount(grains,type,epsilon,varargin)


[phase uphase] = get(grains,'phase');

for k=1:numel(uphase)
  
  grains_phase = grains(phase == uphase(k));
    
  pair = pairs(grains_phase);
  pair(pair(:,1) == pair(:,2),:) = []; % delete self reference
  
  t(k) = size(pair,1);
  
  o = get(grains_phase,'orientation');
  om = o(pair(:,1)) .\ o(pair(:,2));
  
  if isa(type,'quaternion')
        
    c(k) = sum(find(om,type,epsilon));
    
  elseif isa(type,'vector3d')
    
    c(k) = sum(angle(axis(o),type) <= epsilon);
    
  elseif isa(type,'double')
    
    c(k) =  sum(abs(angle(om)-type) <= epsilon);
    
  end
  
end

C = diag(c./t);
  