function [values,nodes,weights] = evalOnCCGridUseSymmetries(SO3F,N,SRight,SLeft,varargin)
% This funtion evaluates a rotational function handle efficiently on clenshaw
% curtis quadrature nodes by using right and left symmetry properties. 
% Hence we evaluate the function handle on a fundamental region concerning 
% the symmetries.
% Rotations around Z axis yields periodic function values on the Clenshaw 
% Curtis quadrature grid. Hence they are ignored, because they are also
% ignored in the quadratureV2 algorithm.

LId = SLeft.id;
RId = SRight.id;

% ignore symmetry by using 'complete' grid
if check_option(varargin,'complete') || (LId==1 && RId==1) || N<=5
  [nodes,weights] = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft,'complete','ABG');
  values = SO3F.eval(nodes);
%   [a,b,c] = Euler(nodes,'nfft');
%   nodes = cat(4,a,b,c);
  return
end



% check for suiting bandwidth
[~,~,g] = fundamentalRegionEuler(SRight,SLeft,'ABG');
t = N;
LCM = lcm((1+double(round(2*pi/g/SRight.multiplicityZ) == 4))*SRight.multiplicityZ,SLeft.multiplicityZ);
while mod(2*t+2,LCM)~=0
  t = t+1;
end
if t~=N
  error(['When trying to evaluate the function on the Clenshaw-Curtis quadrature',...
         'grid with bandwidth %i using the symmetries, an error was detected.',...
         'The specified bandwidth does not fit the symmetries. ' ...
         'Use bandwidth %i instead.'],N,t);
end




% Get Clenshaw Curtis quadrature nodes suitable to the symmetries
nodes = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft,'ABG');


% 1) Are there mirroring symmetries along alpha or gamma
MirrorA = false;
MirrorB = false;
MirrorG = 0;
[a,~,g] = fundamentalRegionEuler(SRight,SLeft,'ABG');
[ae,~,ge] = Euler(nodes(end,2,end),'nfft');
[~,be,~] = Euler(nodes(2,end,2),'nfft');
if abs(2*pi/a - SLeft.multiplicityZ) > 1e-3
  MirrorA = true;
end
if abs(2*pi/g - SRight.multiplicityZ) > 1e-3
  MirrorG = round(pi/g/SRight.multiplicityZ);    % has values {0,1,2} (number of mirroring axis)
end
if abs(be - pi/2) < 1e-3
  MirrorB = true;
end



% 2) If Mirroring: In some special cases we need to evaluate the function handle in additional nodes
addNodesA = false;
addNodesG = false;
% test for 2-fold mirror symmetry along alpha && next grid point is boundary of fundamental region
if MirrorA && abs(ae+pi/(N+1)-a)<1e-3
  addNodesA = true;
  warning off
  nodes = cat(3,nodes,rotation.byEuler(pi/(N+1),0,0).*nodes(:,:,end));
  warning on
end
if MirrorG>0 && abs(ge+pi/(N+1)-g)<1e-3
  addNodesG = true;
  warning off
  nodes = cat(1,nodes,nodes(end,:,:).*rotation.byEuler(pi/(N+1),0,0));
  warning on
end

% TODO: Output this fundamental grid
% TODO: Maybe use unique function in special cases  '432', '23'


% 3) get necessary evaluations
evalues = SO3F.eval(nodes(:));
s = size(evalues);
evalues = reshape(evalues, length(nodes), []);


% 4) Reconstruct Y-axis symmetries
num = size(evalues, 2);
len = (2*N+2)^2*(2*N+1)/(SRight.multiplicityZ*SLeft.multiplicityZ);
values = zeros(len,num);

for index = 1:num

  v = reshape(evalues(:,index),size(nodes));


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
% 1:2 , 3:5 , 6:8 , 9:11, 12:16 , 17:18 , 19:21 , 22:24 , 25:27 , 28:32 , 33:35, 36:40 , 41:42 , 43:45

   % 4.2) If one of the symmetries implies a 2-fold mirror symmetry along
   %      2nd Euler angle beta we may reconstruct full size of values
   if MirrorB

    values_right = flip(v(:,1:end-1,:),2);
    
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

  values(:,index) = v(:);

end

% resize values
values = reshape(values,[len s(2:end)]);


% 4) Construct suitable nodes and weights:
% Ignore symmetry by property 'complete' and make dimensions of nodes,
% weights and values matching to each other.
% If left symmetry includes an r-fold rotation around Z axis and right
% symmetry includes an s-fold rotation around Z axis, then we have to 
% multiply the weights with r*s.
% [nodes, weights] = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft,'Zfold','Euler');
[nodes, weights] = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft,'Zfold','ABG');

end


function TEST

clear
rng(0)
f = SO3FunRBF(orientation.rand(50,'Bunge'),SO3DeLaValleePoussinKernel(20));
F = SO3FunHarmonic(f);

S = {'1','211','121','112','222','3','321','312','4','422','6','622','23','432'};
fprintf('\n New iteration \n')
E = NaN(14,14,4);
for s = 1:4
for i = 1:14
  for j = 1:14
    switch s
      case 1
        CS = crystalSymmetry(S{i});
        SS = crystalSymmetry(S{j});
      case 2
        CS = crystalSymmetry(S{i});
        SS = specimenSymmetry(S{j});
      case 3
        CS = specimenSymmetry(S{i});
        SS = crystalSymmetry(S{j});
      case 4
        CS = specimenSymmetry(S{i});
        SS = specimenSymmetry(S{j});
    end

    if (CS.id==22 && isa(CS,'specimenSymmetry')) || (SS.id == 22 && isa(SS,'specimenSymmetry'))
      continue;
    end

    f = F; f.CS=CS; f.SS=SS; f2=f.symmetrise;

    [a,b,g] = fundamentalRegionEuler(CS,SS,'ABG');
    bw = [];
    for N = 10+(0:30)
      t = N;
      LCM = lcm((1+double(round(2*pi/g/CS.multiplicityZ) == 4))*CS.multiplicityZ,SS.multiplicityZ);
      while mod(2*t+2,LCM)~=0
        t = t+1;
      end
      bw = [bw,t];
    end
    bw = unique(bw);
    for k=1:length(bw)
      [values,nodes,~] = evalOnCCGridUseSymmetries(f2,bw(k),CS,SS);
      A = f2.eval(nodes);
      E(i,j,s) = sum([E(i,j,s) , norm(A(:)-values(:))],'omitnan');
    end

    w = waitbar((j+(i-1)*14+(s-1)*14*14)/(14*14*4));
  end
end
end
close(w);

max(E,[],3,'omitnan')

end

