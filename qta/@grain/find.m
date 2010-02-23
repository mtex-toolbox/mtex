function grains = find(grains,q0,epsilon,varargin)


[phase uphase] = get(grains,'phase');

sel = false(size(phase));
for k=1:numel(uphase)
  ndx = find(phase == uphase(k));
  grains_phase = grains(ndx);
  
  o = get(grains_phase,'orientation');  
  
  if check_option(varargin,'misorientation')
        
    pair = pairs(grains_phase);
    pair(pair(:,1) == pair(:,2),:) = [];
    
    om = o(pair(:,1)) \ o(pair(:,2));
    
    ind = find(om, q0, epsilon);
    
    sel(ndx(pair(ind,:))) = true;    

  else
    
    ind = find(o,q0,epsilon);    
    sel(ndx(ind)) = true;

  end
  
end

grains = grains(sel);