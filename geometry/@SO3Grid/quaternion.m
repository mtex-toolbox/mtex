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
  
  if length(SO3G) > 1  
    for i = 1:length(SO3G) % this can be done faster
      if rotangle(SO3G(i).center) > 1e-10
        SO3G(i).Grid = reshape(SO3G(i).Grid * SO3G(i).center,1,[]);
      else
        SO3G(i).Grid = reshape(SO3G(i).Grid,1,[]);
      end
    end
    N = [SO3G.Grid];
  else
    if rotangle(SO3G.center) > 1e-10
      N = reshape(SO3G.Grid * SO3G.center,1,[]);
    else
      N = reshape(SO3G.Grid,1,[]);
    end    
  end
elseif nargin == 2
  N = reshape(SO3G.Grid(i)*SO3G.center,size(i));
else
  N = SO3G.Grid(i,j)*SO3G.center;
end
