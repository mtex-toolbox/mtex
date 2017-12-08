function cS = rotate(cS,rot)

% if required duplicate the faces
if length(rot)>1 && size(cS.V,2)==1
  shift = length(cS.V) * repmat((0:length(rot)-1),size(cS.F,1),1);
  shift = repmat(shift(:),1,size(cS.F,2));

  cS.F = repmat(cS.F,length(rot),1) + shift;
  
end

cS.V = (rot * cS.V).';

