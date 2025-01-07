function f = example(varargin)
% Construct the sinc function as example for an S1FunHandle.

f = S1FunHandle(@(o) sinc(5*(o-pi)));

end

function d = sinc(o)
  d = sin(o)./o;
  ind = abs(o)<1e-8;
  d(ind) = cos(o(ind));
end