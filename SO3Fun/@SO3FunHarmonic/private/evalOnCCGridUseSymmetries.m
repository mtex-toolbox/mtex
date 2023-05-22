function [values,nodes,weights] = evalOnCCGridUseSymmetries(SO3F,N,SRight,SLeft,varargin)
% This funtion evaluates a rotational function handle efficiently on clenshaw
% curtis quadrature nodes by using right and left symmetry properties. 
% Hence we evaluate the function handle on a fundamental region concerning 
% the symmetries.
% Rotations around Z axis yields periodic function values on the Clenshaw 
% Curtis quadrature grid and are therefore ignored, because they are also
% ignored in the quadratureV2 algorithm.

LId = SLeft.id;
RId = SRight.id;
bothPerpZ = SRight.multiplicityPerpZ~=1 && SLeft.multiplicityPerpZ~=1;

% ignore symmetry by using 'complete' grid
if check_option(varargin,'complete') || (LId==1 && RId==1)
  [nodes,weights] = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft,'complete');
  values = SO3F.eval(nodes(:));
  [a,b,c] = Euler(nodes,'nfft');
  nodes = cat(4,a,b,c);
  return
end

% Get Clenshaw Curtis quadrature nodes suitable to the symmetries
nodes = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft);


% 1) in some special cases we need to evaluate the function handle in additional nodes
addNodes = true;
if ~bothPerpZ
  addNodes = false;
end
if ismember(LId,19:21) && (iseven(N) && (isa(SLeft,'specimenSymmetry') || ismember(RId,[1:2,9:11,17:18,22:35,43:45])))
  addNodes = false;
end
if ismember(RId,19:21) && iseven(N) && ~ismember(LId,6:8) && ~(isa(SLeft,'crystalSymmetry') && ismember(LId,19:21))
  addNodes = false;
end
if ismember(LId,22:24) && (isa(SLeft,'specimenSymmetry') || SRight.multiplicityPerpZ==1) && (isa(SLeft,'crystalSymmetry') || mod(N+1,12)~=0)
  addNodes = false;
end
if ismember(RId,22:24) && iseven(N) && ~ismember(LId,6:8)
  addNodes = false;
end
if ismember(LId,3:5) && iseven(N)
  addNodes = false;
end
if ismember(RId,3:5) && ~ismember(LId,19:24) && iseven(N) && ~ismember(LId,6:8)
  addNodes = false;
end

% add the additional nodes
if addNodes
  nodes = cat(3,nodes,rotation.byEuler(pi/(N+1),0,0).*nodes(:,:,end));
end


% 2) in some special cases we need to shift the nodes along 1st Euler angle alpha
shift = 0;
if SRight.multiplicityPerpZ ~=1
  switch LId
    case {3,4,5}
      shift = ceil((N+1)/2);
    case {19,20,21}
      if isa(SLeft,'specimenSymmetry')
        shift = ceil((N+1)/6);
      else
        shift = 0;
      end
    case {22,23,24}
      if isa(SLeft,'specimenSymmetry')
        shift = ceil((N+1)/4);
      else
        shift = ceil((N+1)/6);
      end
  end
end
warning off
nodes = rotation.byEuler(pi/(N+1)*shift,0,0).*nodes;
warning on


% 3) get necessary evaluations
% TODO: probably use unique function in special cases 
% diagonal symmetry axis --> choose N nicely
evalues = SO3F.eval(nodes(:));
s = size(evalues);
evalues = reshape(evalues, length(nodes), []);

num = size(evalues, 2);
len = (2*N+2)^2*(2*N+1)/(SRight.multiplicityZ*SLeft.multiplicityZ);
values = zeros(len,num);

for index = 1:num

  v = reshape(evalues(:,index),size(nodes));


  % 4) If one of the symmetries includes a 2-fold rotation around Y axis,
  %    we reconstruct full size of values along the 2nd euler angle beta
  if SRight.multiplicityPerpZ~=1 || SLeft.multiplicityPerpZ~=1
    values_right = flip(v(:,1:end-1,:),2);
    
    if SRight.multiplicityPerpZ==1 && SLeft.multiplicityPerpZ~=1
      values_right = flip(values_right,3);
      values_right = circshift(values_right,1,3);
    elseif SRight.multiplicityPerpZ~=1 && ismember(LId,[3:8,19:24])
      values_right = flip(values_right,3);
    else
      values_right = flip(circshift(values_right,-1,1),1);
    end

    if ismember(LId,[1:2,17:18]) || (ismember(LId,6:8) && SRight.multiplicityPerpZ==1)
      values_right = fftshift(values_right,3);
    end
    if ismember(RId,[1:2,6:8,17:18]) || (ismember(RId,[3:5,19:24]) && ismember(LId,[3:8,19:24]))
      values_right = fftshift(values_right,1);
    end
    if isa(SLeft,'crystalSymmetry') && ismember(LId,19:21) && SRight.multiplicityPerpZ==1
      values_right = fftshift(values_right,3);
    end
    if isa(SLeft,'specimenSymmetry') && ismember(LId,22:24) && SRight.multiplicityPerpZ==1
      values_right = circshift(values_right,(N+1)/6,3);
    end
    if isa(SRight,'crystalSymmetry') && ismember(RId,19:21) && ismember(LId,[1:2,9:18,25:45])
      values_right = fftshift(values_right,1);
    end
    if isa(SRight,'specimenSymmetry') && ismember(RId,22:24) && ismember(LId,[1:2,9:18,25:45])
      values_right = circshift(values_right,-(N+1)/6,1);
    end
  
    v = cat(2,v,values_right);
  end


  % 5) If both symmetries has 2-fold rotation around Y axis we have an 
  % additional inner mirror symmetry in 1st euler angle alpha. We use this
  % to redouble the values along 1st euler angle alpha
  if bothPerpZ
    if addNodes
      values_below = v(:,:,2:end-1);
    else
      values_below = v;
    end
    values_below = flip(circshift(flip(values_below,3),-1,1),1);

    if ismember(RId,[3:5,22:24])
      values_below = fftshift(values_below,1);
    end
    if isa(SRight,'specimenSymmetry') && ismember(RId,19:21)
      values_below = fftshift(values_below,1);
    end
    if isa(SRight,'specimenSymmetry') && ismember(RId,22:24)
      values_below = circshift(values_below,-(N+1)/6,1);
    end

    v = cat(3,v,values_below);
    v = circshift(v,shift,3);
  end

  values(:,index) = v(:);

end

% resize values
values = reshape(values,[len s(2:end)]);


% Construct suitable nodes and weights:
% Ignore symmetry by property 'complete' and make dimensions of nodes,
% weights and values matching to each other.
% If left symmetry includes an r-fold rotation around Z axis and right
% symmetry includes an s-fold rotation around Z axis, then we have to 
% multiply the weights with r*s.
[nodes, weights] = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft,'Zfold','Euler');

end
