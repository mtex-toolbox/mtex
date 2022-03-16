function [values,nodes,weights] = eval_onCCGrid_useSym(F,N,CS,SS)
% We want to evaluate a function handle on the rotation group in clenshaw
% curtis quadrature nodes by using crystal and specimen symmetry. Hence
% we evaluate the function handle on a fundamental region concerning the
% symmetries.
% Rotations around Z axis in crystal and specimen symmetries yields periodic
% function values on Clenshaw Curtis quadrature grid and are therefore ignored

% Get nodes by ClenshawCurtis quadrature
nodes = quadratureSO3Grid(2*N,'ClenshawCurtis',CS,SS);

% if crystal and specimen symmetry both has 2-fold rotation around Y axis
% we have an additional (possibly shifted) inner mirror symmetry in 1st 
% euler angle alpha
if CS.multiplicityPerpZ~=1 && SS.multiplicityPerpZ~=1

  % if crystal symmetry has 2-fold rotation around Y axis and specimen
  % symmetry is '321' or '312' we have to shift the nodes in 1st euler angle
  % alpha by pi/6 or pi/4
  warning('off')
  if SS.id==19
    shift = ceil(N/6);
    nodes = rotation.byEuler(pi/(N+1)*shift,0,0).*nodes;
  elseif SS.id==22
    shift = ceil(N/4);
    nodes = rotation.byEuler(pi/(N+1)*shift,0,0).*nodes;
  else
    shift=0;
  end

  % in some special cases we need to evaluate the function handle in additional nodes
  if (SS.id==19 && mod(N+1,2)==0) || (SS.id==22 && mod(N+1,12)==0) || (SS.id~=19 && SS.id~=22)
    nodes = cat(3,nodes,rotation.byEuler(2*pi/(2*N+2),0,0).*nodes(:,:,end));
  end
  warning('on')
end

% evaluate on fundamental region
evalues = F(nodes(:));


s = size(evalues);
evalues = reshape(evalues, length(nodes), []);
num = size(evalues, 2);

len = (2*N+2)^2*(2*N+1)/(CS.multiplicityZ*SS.multiplicityZ);
values = zeros(len,num);
for index = 1:num

  v = reshape(evalues(:,index),size(nodes));

  % redouble values along 1st euler angle alpha by use of inner mirror 
  % symmetry in 1st euler angle alpha
  if CS.multiplicityPerpZ~=1 && SS.multiplicityPerpZ~=1
    if (SS.id==19 && mod(N+1,2)~=0) || (SS.id==22 && mod(N+1,12)~=0)
      values_below = flip(circshift(flip(v,3),-1,1),1);
    else
      values_below = flip(circshift(flip(v(:,:,2:end-1),3),-1,1),1);
    end
    if CS.id==22
      values_below = fftshift(values_below,1);
    end
    v = cat(3,v,values_below);
    v = circshift(v,shift,3);
  end


  % if crystal or specimen symmetry includes 2-fold rotation around Y axis,
  % we construct full size of values along the 2nd euler angle beta
  if CS.multiplicityPerpZ~=1 || SS.multiplicityPerpZ~=1
  
    values_right = flip(v(:,1:end-1,:),2);
    if CS.multiplicityPerpZ==1 && SS.multiplicityPerpZ~=1
      values_right = flip(circshift(values_right,-1,3),3);
    else
      values_right = flip(circshift(values_right,-1,1),1);
    end

    if SS.multiplicityZ==1 || (SS.multiplicityZ==3 && CS.multiplicityPerpZ~=1)
      values_right = fftshift(values_right,3);
    end
    if CS.multiplicityZ==1 || (CS.multiplicityZ==3 && CS.id~=22)
      values_right = fftshift(values_right,1);
    end
    if CS.multiplicityPerpZ==1 && SS.id==22
      values_right = circshift(values_right,(N+1)/6,3);
    end

    v = cat(2,v,values_right);

  end

  values(:,index) = v(:);

end

values = reshape(values,[len s(2:end)]);

% ignore symmetry by property 'complete' and make dimensions of nodes
% weights and values matching to each other
% If crystal symmetry includes r-fold rotation around Z axis and specimen
% symmetry includes s-fold rotation around Z axis, then multiply with r*s.
[nodes, weights] = quadratureSO3Grid(2*N,'ClenshawCurtis',CS,SS,'complete');
nodes = nodes(1:(2*N+2)/CS.multiplicityZ,:,1:(2*N+2)/SS.multiplicityZ);
rs = CS.multiplicityZ*SS.multiplicityZ;
weights = weights(1:(2*N+2)/CS.multiplicityZ,:,1:(2*N+2)/SS.multiplicityZ)*rs;

end