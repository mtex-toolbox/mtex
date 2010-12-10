function ebsd = inpolygon(ebsd,varargin)
% select spatial ebsd data by a given polygon

XY = get(ebsd,'xy');

if ~isempty(XY)
  p = polygon(varargin{:});
  ind = false(size(XY,1),1);
  for k=1:numel(p)
    xy = get(p(k),'vertices');
    ind = ind | inpolygon(XY(:,1),XY(:,2),xy(:,1),xy(:,2));
  end

  ebsd = delete(ebsd,~ind);
end