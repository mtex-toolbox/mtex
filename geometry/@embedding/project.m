function [ori, Tori,i] = project(obj,ori,varargin)
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

% normalize obj correctly
obj = obj .* norm(Tid)./norm(obj);

%get weights beta
%[~,~,weights]= embedding.coefficients(obj.CS);

% ensure obj is symmetric
%obj = obj.sym;

% special case for triclinic symmetry 
% TODO: check this!
if 0 && obj.CS.Laue.id == 2
  
  % weighted sum in Horn
  for i = 1:length(obj.u) %#ok<UNRCH>
    r(i,:) = obj.u{i}(:); %#ok<AGROW>
  end
  
  ori = orientation(fit(obj.l,r,obj.CS),obj.CS);
  
  if nargout == 2, Tori = ori * Tid; end
  return
  
end

% initial guess - we need it to be sufficiently close to avoid local extrema
if nargin == 1 || isempty(ori)
  ori = equispacedSO3Grid(obj.CS,'points',10);
  
  d = norm(reshape(obj,[],1) - (ori * Tid).');

  [~,id] = min(d,[],2);
  
  ori = reshape(ori(id),[],1);
  %ori = orientation.id(obj.CS); 
end

% basis of the tangential space
t = spinTensor([xvector,yvector,zvector]);

if check_option(varargin,'nesterov')
  % this is the nestorov accelerated gradient method
  % it does not work as good as expected
  % for some reason plain gradient is converges faster
  
  xOri = ori;
  eta = vector3d.zeros(size(xOri));
  tk = 1;
  
  % perform Nesterov iteration to maximize dot(ori * Tid, obj)
  maxIter = 200;
  for i = 1:maxIter
  
    % 1. lookahead point
    yOri = exp(xOri, eta, SO3TangentSpace.leftVector);
    
    % 2. gradient at lookahead point
    Tori = rotate_outer(Tid,yOri);
    for k = 1:length(obj.u)
      Tori.u{k} = obj.rank(k) * EinsteinSum(t,[1,-1],Tori.u{k},[-1 2:obj.rank(k)]);
    end
    g = vector3d(dot(Tori,obj).').';
      
    % 3. gradient step
    xOri = exp(yOri, g, SO3TangentSpace.leftVector);

    % 4. Update Nesterov coefficients:
    tk1 = (1+sqrt(1+4*tk^2))/2;
    betak = (tk-1)/tk1;
    tk = tk1;

    % 5. new momentum
    eta = 0.1*(betak * eta + g);
    
    % stop if gradient is sufficiently small
    if all(norm(g)<1e-10), break; end
    disp([xnum2str(i,'fixedWidth',3) ' ' xnum2str(max(norm(g)),'fixedWidth',8) ' ' char(ori(1)) ' ' char(g(1))]);
      
  end
  ori = xOri;

else
  
  % perform steepest descent iteration to maximize dot(ori * Tid, obj)
  maxIter = 200;
  for i = 1:maxIter
  
    % compute the gradient in ori
    Tori = rotate_outer(Tid,ori);
    for k = 1:length(obj.u)
      Tori.u{k} = obj.rank(k) * EinsteinSum(t,[1,-1],Tori.u{k},[-1 2:obj.rank(k)]);
    end
  
    g = vector3d(dot(Tori,obj).').';
      
    % eradicate normalizing of embedding: adapt length of gradient
    % g = g * obj.rho^2;
  
    % stop if gradient is sufficiently small
    if all(norm(g)<1e-10), break; end
    disp([xnum2str(i,'fixedWidth',3) ' ' xnum2str(max(norm(g)),'fixedWidth',8) ' ' char(ori(1)) ' ' char(g(1))]);
  
    % update ori
    ori = exp(ori, g, SO3TangentSpace.leftVector);
  
  end
end

end


function test %#ok<DEFNU>

cs = crystalSymmetry('432');
ori = orientation.rand(10,cs);

emb = mean(embedding(ori));

tic
orientation(emb)
toc


end

