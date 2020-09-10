function [ori, Tori] = project(obj,ori)
% project an embedding back onto the manifold of orientations.
%
% Syntax
%   [ori, Tori] = project(e)
%
% Input
%  e - @embedding
%
% Output
%  ori - @orientation
%  Tori - projected @embedding
%

% get the embedding of the identity
Tid = embedding.id(obj.CS);

%get weights beta
[~,~,weights]= embedding.coefficients(obj.CS);

% ensure obj is symmetric
%obj = obj.sym;

% special case for triclinic symmetry
if obj.CS.Laue.id ==2
  
  %weighted sum in Horn
  for i = 1:length(obj.u)
    r(i,:) = obj.u{i}(:);
  end
  
  ori = orientation(fit(obj.l,r,obj.CS),obj.CS);
  
  if nargout == 2, Tori = ori * Tid; end
  return
  
end

% initial guess
if nargin == 1, ori = orientation.id(obj.CS); end

% basis of the tangential space
t = spinTensor([xvector,yvector,zvector]);

% perform steepest descent iteration to maximize dot(ori * Tid, obj)
maxIter = 100;
for i = 1:maxIter
  
  % compute the gradient in ori
  Tori = rotate_outer(Tid,ori);
  for k = 1:length(obj.u)
    Tori.u{k} =obj.rank(k) * EinsteinSum(t,[1,-1],Tori.u{k},[-1 2:obj.rank(k)]);
  end
  
  g = vector3d(dot(Tori,obj).');
  
  % stop if gradient is sufficently small
  if all(norm(g)<1e-10),break; end
  
  % eradicate normalizing of embedding: adapt length og gradient
  g = g* embedding.radius_sphere(obj.CS);
  
  % update ori
  ori = exp(ori,g,'left');
  
end
end
%%Function fit for C1
function rot = fit(l,r,cs)
[~,alpha,weights] = embedding.coefficients(cs);
for k =1:1:length(r)/3
    N = zeros(4,4,1000);
for i = 1:1:length(l)

    M{i}=l(i)*r(i,k);
    MS{i} = M{i} + M{i}';
    MA{i} = M{i} - M{i}';
     NN{i} = [trace(M{i}) MA{i}(2,3)             MA{i}(3,1)              MA{i}(1,2);
            MA{i}(2,3)    M{i}(1,1)-M{i}(2,2)-M{i}(3,3) MS{i}(1,2)              MS{i}(1,3);
            MA{i}(3,1)    MS{i}(1,2)              M{i}(2,2)-M{i}(1,1)-M{i}(3,3) MS{i}(2,3);
            MA{i}(1,2)    MS{i}(1,3)              MS{i}(2,3)              M{i}(3,3)-M{i}(1,1)-M{i}(2,2)];
 if length(alpha)==1
        N(:,:,k) = N(:,:,k)+NN{i}^(alpha(1));
 else
     N(:,:,k) = N(:,:,k)+weights(i)*NN{i}^(alpha(i));
 end
end
 

[V(:,:,k),lambda] = eig(N(:,:,k));

[~,idx] = sort(diag(lambda));
for i=1:1:length(idx)
W(:,i)=V(:,idx(i),k);
end
V(:,:,k) = W;


% if length(l)== 3 && -min(lambda)>max(lambda)
%   
%   r(end) = -r(end);
%   rot = fit(l,r,cs);
  
% else
 
  rot(k) = rotation(quaternion(V(:,4,k)));

  
% end
end
end