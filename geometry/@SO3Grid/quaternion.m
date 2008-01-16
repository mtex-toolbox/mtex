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
    N = quaternion;
    for i = 1:length(SO3G)      
        N = [N,SO3G(i).Grid]; %#ok<AGROW>
    end
elseif nargin == 2
    N = SO3G.Grid(i);
else
    N = SO3G.Grid(i,j);
end
