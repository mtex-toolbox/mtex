function [ev,ew]= principalcomponents(grains,varargin)
% returns the principalcomponents of grain polygon, without Holes
%
%% Input
%  grains - @GrainSet
%
%% Output
%  cmp   - angle of components as complex
%  v     - length of axis
%
%% Options
%  HULL  - components of convex hull
%
%% See also
% polygon/hullprincipalcomponents grain/plotEllipse
%

V = full(grains.V);
F = full(grains.F);
dim = size(V,2);

I_VF = grains.I_VF;
[v,f] =  find(I_VF);
halfDist = sqrt(sum((V(F(f,1),:) - V(F(f,2),:)).^2,2))/2;
I_VFweight = sqrt(sparse(v,f,halfDist,size(I_VF,1),size(I_VF,2)));
I_VGweight = I_VFweight * abs(grains.I_FDext) * grains.I_DG;


[v,g,weight] = find(I_VGweight);
cs = [0; find(diff(g));size(g,1)];

d = zeros(size(grains));

c = centroid(grains);

ew = zeros(dim,dim,numel(grains));
ev = zeros(dim,dim,numel(grains));
for k=1:size(grains,1)
  ndx = cs(k)+1:cs(k+1);
  Vg = bsxfun(@minus,V(v(ndx),:), c(k,:));
  Vg = bsxfun(@times,Vg, weight(ndx));
  

  % pca
  [ev(:,:,k)  ew(:,:,k)] = svd(Vg'*Vg);
  ew(:,:,k)  = nthroot(dim*sqrt(dim).*ew(:,:,k),dim)./(nthroot(size(Vg,1),dim));
end



if nargout < 1
  plotBoundary(grains,'facealpha',0.2);
  
  ng = size(grains,1);
  % center = cell(numel(grains));
  ax1 = cell(ng,1);
  ax2 = cell(ng,1);
  
  for k=1:ng
    v = ev(:,:,k)*ew(:,:,k);
    
    center = bsxfun(@times,c(k,:),ones(dim,1));
    ax1{k} = center+v';
    ax2{k} = center-v';
  end
  
  ax1 = vertcat(ax1{:});
  ax2 = vertcat(ax2{:});  
  
  fac = [1:size(c,1); size(c,1)+1:2*size(c,1)]';
  h(1) = patch('vertices', [ax1(1:dim:size(ax1,1),:); ax2(1:dim:size(ax1,1),:)],'faces',fac,'edgecolor','b','facecolor','none');
  h(2) = patch('vertices', [ax2(2:dim:size(ax1,1),:); ax1(2:dim:size(ax1,1),:)],'faces',fac,'edgecolor','g','facecolor','none');
  
  if dim == 3
    h(3) = patch('vertices', [ax2(3:dim:size(ax1,1),:);ax1(3:dim:size(ax1,1),:)],'faces',fac,'edgecolor','r','facecolor','none');
  end
  
  optiondraw(h,varargin{:})
end


