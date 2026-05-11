function plot3d(SO3F,varargin)
% plots odf

if numel(SO3F)>1 && ~getMTEXpref('generatingHelpMode')
  warning(['You try to plot a vector valued function. Plot the desired components ' ...
    'manually. In the following the first component is plotted.'])
end

plot3d@SO3Fun(SO3F.subSet(1),varargin{:});

end