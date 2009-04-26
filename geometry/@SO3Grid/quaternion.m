function N = quaternion(SO3G,i,j)
% convert to quaternion
%% Syntax
%  N = quaternion(SO3G,i,j)
%
%% Input
%  SO3G   - @SO3Grid
%  indece - int32 (optional)
%% Output
%  @quaternion

if nargin == 1  
  for i = 1:length(SO3G)
    SO3G(i).Grid = reshape(SO3G(i).Grid * SO3G(i).center,1,[]);
    N = [SO3G.Grid];
  end
elseif nargin == 2
  N = reshape(SO3G.Grid(i)*SO3G.center,size(i));
else
  N = SO3G.Grid(i,j)*SO3G.center;
end
