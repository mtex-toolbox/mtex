function S1F = mtimes(a,b,varargin)

if isa(a,'S1FunHarmonic')

  S1F = a;
  S1F.fhat = S1F.fhat * b;

elseif isa(b,'S1FunHarmonic')

else

end
