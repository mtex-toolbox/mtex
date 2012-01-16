function ebsd = findByLocation( ebsd, xy )

if all(isfield(ebsd.options,{'x','y','z'}))
  x_D = get(ebsd,'xyz');
elseif all(isfield(ebsd.options,{'x','y'}))
  x_D = get(ebsd,'xy');
else
  error('mtex:findByLocation','no Spatial Data!');
end

delta = 1.5*mean(sqrt(sum(diff(ebsd.unitCell).^2,2)));

x_Dm = x_D-delta;  x_Dp = x_D+delta;

nd = sparse(numel(ebsd),size(xy,1));
dim = size(x_D,2);
for k=1:size(xy,1)
  
  candit = find(all(bsxfun(@le,x_Dm,xy(k,:)) & bsxfun(@ge,x_Dp,xy(k,:)),2));
  dist = sqrt(sum(bsxfun(@minus,x_D(candit,:),xy(k,:)).^2,2));
  [dist i] = min(dist);
  nd(candit(i),k) = 1;
  
end

ebsd = subsref(ebsd,any(nd,2))




