function plot(SO3F,varargin)
% plots odf or append to a previous plot using 'add2all'
%
% Syntax
%
%   % plot in phi2 sections
%   plot(odf)
%
%   % plot in specific phi2 sections
%   plot(odf,'phi2',45*degree)
%
%   % plot in 3d space
%   plot(odf,'axisAngle')
%   plot(odf,'rodrigues')
%   
%   % plot along a fibre
%   f = fibre.alpha(odf.CS)
%   plot(odf,f)
%
%   % plot the odf as sigma sections
%   oS = sigmaSections(odf.CS)
%   plot(odf,oS)
%
% See also
% SO3Fun/plotSection SO3Fun/plot3d SO3Fun/plotFibre

if numel(SO3F)>1
  warning(['You try to plot an multivariate function. Plot the desired components ' ...
    'manually. In the following the first component is plotted.'])
end

plot@SO3Fun(SO3F.subSet(1),varargin{:});

end
