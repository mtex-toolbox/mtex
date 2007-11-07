function d = dist(CS,SS,g1,g2,varargin)
% calcualtes distance between rotations g1 and g2 modulo symmetry
%% Syntax
%  d = dist(CS,SS,g1,g2)
%
%% Input
%  CS     - crystal @symmetry
%  SS     - specimen @symmetry
%  g1, g2 - @quaternion
%
%% Options
%  all - return all distances
% 
%% Output
%  d - distance, dimension: g1 x g2 x symmetry

g1 = reshape(g1,1,[]);
g2 = reshape(g2,1,[]);

l1 = length(g1);
l2 = length(g2);
lCS = length(CS.quat);
lSS = length(SS.quat);

if l1 < l2
  g1rot = reshape(reshape(SS.quat * g1,[],1) * CS.quat.',[lSS l1 lCS]);
  g1rot = shiftdim(g1rot,-1);                    % -> CS x SS x g1
  
  d = reshape(dist(g1rot,g2),[lCS * lSS,l1,l2]); %-> CS * SS x g1 x g2
  d = shiftdim(d,1);                             %-> g1 x g2 x CS * SS
else
  g2rot = reshape(reshape(SS.quat * g2,[],1) * CS.quat.',[lSS l1 lCS]);
  g2rot = shiftdim(g2rot,1);                     % -> g2 x CS x SS
  
  d = reshape(dist(g1,g2rot),[l1,l2,lCS * lSS]);
end

if ~check_option(varargin,'all')
  d = min(d,[],3);
end
