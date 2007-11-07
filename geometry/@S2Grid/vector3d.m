function v = vector3d(S2G,i,j)
% converts points to vector3d
%% Input
%  S2G    - @S2Grid
%  indece - theta,rho (optional)
%% Output
%  @vector3d

if nargin == 3
    v = S2G(1).Grid(i,j);
elseif nargin == 2
    v = vector3d;
    for iG = 1:length(S2G)       
        ind = find(i > 0 & i <= GridLength(S2G(iG)));
        v(ind) = S2G(iG).Grid(i(ind));
        i = i - GridLength(S2G(iG));        
    end
elseif length(S2G) == 1
    v = S2G.Grid;
else
    v = vector3d;
    for i = 1:length(S2G)
        v = [v,reshape(S2G(i).Grid,1,[])]; %#ok<AGROW>
    end
end
