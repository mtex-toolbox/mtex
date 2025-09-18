function S2F = S2FunRBF(center,varargin)

psi = getClass(varargin,"S2Kernel");
if isempty(psi)
  psi = S2DeLaValleePoussinKernel(varargin{:});
end

rot = rotation.map(zvector,center);

S2F = rot * S2FunHarmonic(psi);

end


