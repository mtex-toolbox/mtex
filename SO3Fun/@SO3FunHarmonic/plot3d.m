function plot3d(SO3F,varargin)
% plots odf

if numel(SO3F)>1
  warning(['You try to plot an multivariate function. Plot the desired components ' ...
    'manually. In the following the first component is plotted.'])
end
if ~SO3F.isReal
  warning(['Imaginary part of complex valued SO3FunHarmonic is ignored. ' ...
    'In the following only the real part is plotted.'])
  SO3F.isReal=1;
end

plot3d@SO3Fun(SO3F.subSet(1),varargin{:});

end