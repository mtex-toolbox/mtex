function [u,inodes,iu] = uniqueQuadratureSO3Grid(nodes,N,scheme,varargin)
% Nearly disjoint list of orientations of an quadratureSO3Grid.
%
% We use 2-fold rotational symmetries along Y-axis of left and right 
% symmetries to manually 'unique' the fundamental region.
%
% Syntax
%   [u,~,iu] = uniqueQuadratureSO3Grid(nodes,N)
%
% Input
%  nodes - @orientation
%  N - bandwidth
%  scheme - 'ClenshawCurtis' or 'GaussLegendre'
%
% Output
%  u  - @orientation
%  iu - index tensor such that    nodes = u(iu)
%  inodes - index vector such that    u = nodes(inodes)
%
% See also
% orientation.unique SO3FunHarmonic.quadrature SO3FunHarmonic.quadratureNFSOFT


% Note that specimenSymmetry('23') does not exist and consequently does not work

SRight = nodes.CS;
SLeft = nodes.SS;
RId = SRight.id;
LId = SLeft.id;

u = regularSO3Grid(scheme,'bandwidth',2*N,SRight,SLeft,varargin{:},'ABG');


% 1) Are there mirroring symmetries along alpha, beta or gamma
MirrorA = false;
MirrorB = false;
MirrorG = 0;
[a,b,g] = fundamentalRegionEuler(SRight,SLeft,'ABG');
[ae,~,ge] = Euler(u(end,2,end),'nfft');
[~,be,~] = Euler(u(2,end,2),'nfft');
if abs(2*pi/a - SLeft.multiplicityZ) > 1e-3
  MirrorA = true;
end
if abs(2*pi/g - SRight.multiplicityZ) > 1e-3
  MirrorG = round(pi/g/SRight.multiplicityZ);    % has values {0,1,2} (number of mirroring axis)
end
if abs(b - pi/2) < 1e-3
  MirrorB = true;
end



% 2) If Mirroring: In some special cases we need to evaluate the function handle in additional nodes
addNodesA = false;
addNodesB = false;
addNodesG = false;
% test for 2-fold mirror symmetry along alpha && next grid point is boundary of fundamental region
if MirrorA && abs(ae+pi/(N+1)-a)<1e-3
  addNodesA = true;
  warning off
  u = cat(3,u,rotation.byEuler(pi/(N+1),0,0).*u(:,:,end));
  warning on
end
if MirrorG>0 && abs(ge+pi/(N+1)-g)<1e-3
  addNodesG = true;
  warning off
  u = cat(1,u,u(end,:,:).*rotation.byEuler(pi/(N+1),0,0));
  warning on
end
if MirrorB && abs(be - pi/2)<1e-3
  addNodesB = true;
end

v = reshape(1:length(u),size(u));
u = u(:);

if nargout==1
  return
end
  

% 4.1) If one of the symmetries implies a 2-fold mirror symmetry along
%      3rd Euler angle gamma we may reconstruct full size of values
% In some special cases we have two inner mirror symmetries along
% 3rd Euler angle gamma.
%  Hence we redouble the values again along gamma
if MirrorG == 2 % only if SLeft is '211' or '321' or '312'

  if addNodesG
    values_right = flip(v(1:end-1,:,:),1);
  else
    values_right = flip(v(1:end,:,:),1);
  end

  values_right = fftshift(values_right,3);
  if (ismember(RId,6:8)) ...
      || (ismember(RId,19:21) && isa(SRight,'crystalSymmetry'))
    values_right = flip(values_right,2);
  elseif (ismember(RId,3:5)) ...
      || ( ismember(RId,19:21) && isa(SRight,'specimenSymmetry') ) ...
      || ( ismember(RId,22:24) && isa(SRight,'crystalSymmetry') )
    values_right = flip(values_right,3);
    values_right = circshift(values_right,1,3);
  end

  v = cat(1,v,values_right);

end

if MirrorG >= 1 % only if SLeft is '211' or '321' or '312'

  if addNodesG || MirrorG==2
    values_below = v(2:end-1,:,:);
  else
    values_below = v(2:end,:,:);
  end

  values_below = flip(values_below,3);
  if (ismember(RId,3:8)) ...
      || ( ismember(RId,19:21) && isa(SRight,'specimenSymmetry') ) ...
      || ( ismember(RId,22:24) && isa(SRight,'crystalSymmetry') )
    values_below = circshift(values_below,1,3);
    values_below = flip(values_below,2);
  elseif ismember(RId,[12:16,28:32,36:45])
    values_below = flip(values_below,1);
  elseif ismember(RId,19:21) && isa(SRight,'crystalSymmetry')
    values_below = fftshift(values_below,3);
    values_below = circshift(values_below,1,3);
    values_below = flip(values_below,1);
  end


  v = cat(1,v,values_below);

end

% 4.2) If one of the symmetries implies a 2-fold mirror symmetry along
%      2nd Euler angle beta we may reconstruct full size of values
if MirrorB

  if addNodesB
    values_right = flip(v(:,1:end-1,:),2);
  else
    values_right = flip(v(:,1:end,:),2);
  end

  if SRight.multiplicityPerpZ==1 && SLeft.multiplicityPerpZ~=1
    values_right = flip(values_right,3);
    values_right = circshift(values_right,1,3);
  elseif SRight.multiplicityPerpZ~=1 && ismember(LId,[3:8,19:24])
    values_right = flip(values_right,3);
  else
    values_right = flip(circshift(values_right,-1,1),1);
  end

  if ( ismember(LId,[1:2,17:18]) ) ...
      || ( ismember(LId,6:8) && SRight.multiplicityPerpZ==1 ) ...
      || ( ismember(LId,19:21) && isa(SLeft,'crystalSymmetry') && SRight.multiplicityPerpZ==1 )
    values_right = fftshift(values_right,3);
  end

  if ( ismember(RId,[1:2,6:8,17:18]) ) ...
      || ( ismember(RId,[3:5,19:24]) && ismember(LId,[6:8,19:21]) ) ...
      || ( ismember(RId,19:21) && isa(SRight,'crystalSymmetry') && ismember(LId,[1:2,9:18,25:45]) )
    values_right = fftshift(values_right,1);
  end

  v = cat(2,v,values_right);

end


% 4.3) If one of the symmetries implies a 2-fold mirror symmetry along
%      1st Euler angle alpha we may reconstruct full size of values
if MirrorA

  if addNodesA
    values_below = v(:,:,2:end-1);
  else
    values_below = v(:,:,2:end);
  end

  if ismember(LId,[3:5,22:24])
    values_below = flip(values_below,2);
    values_below = flip(circshift(values_below,-1,1),1);
  elseif isa(SLeft,'specimenSymmetry') && ismember(LId,19:21)
    values_below = flip(values_below,2);
    values_below = flip(circshift(values_below,-1,1),1);
  else
    values_below = flip(values_below,3);
    values_below = flip(circshift(values_below,-1,1),1);
  end

  if ( ismember(RId,3:5) ) ...
      || ( ismember(RId,19:21) && isa(SRight,'specimenSymmetry') ) ...
      || ( ismember(RId,22:24) && isa(SRight,'crystalSymmetry') )
    values_below = fftshift(values_below,1);
  end



  v = cat(3,v,values_below);

end

[~,inodes,~] = unique(v);
iu = v;

end