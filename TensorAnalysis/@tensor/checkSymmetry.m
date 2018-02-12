function out = checkSymmetry(T)

out = true;

if T.rank <= 1, return; end

rot = rotation(T.CS);

for i = 2:length(rot)
  
  if T ~= rotate(T,rot(i))
    out = false;
    if nargout == 0 
      warning('MTEX:tensor','Tensor does not pose the right symmetry');
    end
    return;
  end
end

