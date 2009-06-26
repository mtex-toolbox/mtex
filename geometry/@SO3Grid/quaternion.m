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
      if ~isempty(SO3G(i).center)
        SO3G(i).Grid = reshape(SO3G(i).Grid * SO3G(i).center,1,[]);
      else
        SO3G(i).Grid = reshape(SO3G(i).Grid,1,[]);
      end
    end
    N = [SO3G.Grid];
  else
    if isempty(SO3G.center)
      N = SO3G.Grid;
    else
      N = reshape(SO3G.Grid * SO3G.center,1,[]);      
    end    
  end
elseif nargin == 2
  if ~isempty(SO3G.center)
    N = reshape(SO3G.Grid(i)*SO3G.center,size(i));
  else
    N = SO3G.Grid(i);
  end
else
  if ~isempty(SO3G(i).center)
    N = SO3G.Grid(i,j)*SO3G.center;
  else
    N = SO3G.Grid(i,j);
  end
end
