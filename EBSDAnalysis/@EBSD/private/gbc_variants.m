function criterion = gbc_variants(ori,CS,Dl,Dr,delta,varargin)
errorcheck = all(length(ori)==length(delta) & all(floor(delta) == delta));
assert(errorcheck,'Provide a list of valid variant IDs to compute grains from variant Ids');
% variant grain criterion
% check whether the two ebsd measurements are seperated by a grain boundary
if size(delta,2)>1
    criterion = delta(Dl,1)-delta(Dr,1) + delta(Dl,2)-delta(Dr,2) == 0;
else
    criterion = delta(Dl,1)-delta(Dr,1) == 0;
end

