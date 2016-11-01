function ext = extend(ebsd)
% returns the boundings of spatial EBSD data
%
% Output
% ext - extend as [xmin xmax ymin ymax]
%

ext = [nanmin(ebsd.prop.x(:)) nanmax(ebsd.prop.x(:)) ...
  nanmin(ebsd.prop.y(:)) nanmax(ebsd.prop.y(:))];
