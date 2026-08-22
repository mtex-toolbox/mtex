function d = registerImage(mg)
% the values this image should be cross correlated on
%
% What an image is registered on and what it carries are two different
% things. Copper's reference frame is imported twice, gamma compressed so
% that grain boundaries are visible to the correlation and median filtered so
% that void edges survive for the analysis; declaring the first as a
% registration channel of the second removes the second entry, and with it
% the identity hop that existed only to carry the filtering through.
%
% Syntax
%
%   d = registerImage(mg)
%
% Input
%  mg - @mapImage
%
% Output
%  d - r x c values to correlate
%
% Description
% mg.registerOn says which:
%
%  'edge' - the edge transform, <mapImage.edgeMap.html |edgeMap|>. The
%           default, and what makes a band contrast map comparable to a
%           backscatter image
%  'raw'  - the values as they are, for images that already share contrast.
%           Averaged over channels if there is more than one
%  handle - applied to the values, e.g. @(v) nthroot(v,0.1)
%
% This is work, not a property read. Compute it once per image and keep it.
%
% See also
% mapImage mapImage/edgeMap

if isa(mg.registerOn,'function_handle')

  d = mg.registerOn(mg.img);

  assert(isequal(size(d,[1 2]),gridSize(mg)),...
    'MTEX:mapImage:badRegisterOn',...
    ['A registerOn handle maps values to values on the same grid, but it '...
    'returned %s for a %s image.'],...
    mat2str(size(d)),mat2str(gridSize(mg)));

  if size(d,3) > 1, d = mean(d,3); end

  return

end

switch lower(mg.registerOn)

  case 'edge'
    d = edgeMap(mg);

  case 'raw'
    d = mg.img;
    if size(d,3) > 1, d = mean(d,3); end

  otherwise
    error('MTEX:mapImage:badRegisterOn',...
      'registerOn is ''edge'', ''raw'' or a function handle, got ''%s''.',...
      mg.registerOn);

end

end
