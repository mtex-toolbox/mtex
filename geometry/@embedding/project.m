function [ori, Tori,i] = project(obj,ori)
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
%[~,~,weights]= embedding.coefficients(obj.CS);

% ensure obj is symmetric
%obj = obj.sym;

% special case for triclinic symmetry
if 0 && obj.CS.Laue.id ==2
  
  %weighted sum in Horn
  for i = 1:length(obj.u)
    r(i,:) = obj.u{i}(:);
  end
  
  ori = orientation(fit(obj.l,r,obj.CS),obj.CS);
  
  if nargout == 2, Tori = ori * Tid; end
  return
  
end

% initial guess - we need it to be sufficently close to avoid local extrema
if nargin == 1
  ori = equispacedSO3Grid(obj.CS,'points',10);
  
  d = norm(reshape(obj,[],1) - (ori * Tid).');

  [~,id] = min(d,[],2);
  
  ori = reshape(ori(id),[],1);
  %ori = orientation.id(obj.CS); 
end

% basis of the tangential space
t = spinTensor([xvector,yvector,zvector]);

% perform steepest descent iteration to maximize dot(ori * Tid, obj)
maxIter = 200;
for i = 1:maxIter
  
  % compute the gradient in ori
  Tori = rotate_outer(Tid,ori);
  for k = 1:length(obj.u)
    Tori.u{k} = obj.rank(k) * EinsteinSum(t,[1,-1],Tori.u{k},[-1 2:obj.rank(k)]);
  end
  
  g = vector3d(dot(Tori,obj).').';
  
  % eradicate normalizing of embedding: adapt length ofs gradient
  g = g * obj.rho^2;
  
  % stop if gradient is sufficently small
  if all(norm(g)<1e-10), break; end
  %disp([xnum2str(max(norm(g))) ' ' char(ori(1)) ' ' char(g(1))]);
  
  % update ori
  ori = exp(ori,g,'left');
  
end
end
