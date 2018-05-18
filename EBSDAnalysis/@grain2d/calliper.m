function [cd, pcd, omega] = calliper(grains,varargin)
% Calliper (Feret diameter) of a grain in measurement units, the projection
% length normal to it and its direction/trend.
% 
% Input:
%  grains   - @grain2d
%
% Output:
%  cd       - calliper (default = maximum calliper = grain2d/diameter)
%  pcd      - projection length length normal to cd
%  omega    - angle giving direction/trend of cd
%

% (reusing code from grain2d/diameter)
% Todo :
% add Option: 'shortest': in that case cd will be the minimum calliper,
%             pcd legnth normal to it and omega the angle giving the 
%             trend/direction of cd
%             - probably easy using the projection lengths 

V = grains.V;
poly = grains.poly;
cd = zeros(size(grains)); pcd=cd; omega=cd;


for ig = 1:length(grains)
    Vg = V(poly{ig},:);
    %   % if it is a large Vertex-Set, reduce it to its convex hull
    if size(Vg,1) > 100, Vg = Vg(convhulln(Vg),:); end
    diffVg = bsxfun(@minus,reshape(Vg,[],1,2),reshape(Vg,1,[],2));
    diffVg = sum(diffVg.^2,3);
    
    [md, id ]=max(diffVg(:));

    % find corresponding vertices
    [I,J] = ind2sub(size(diffVg),id);
    
    % first point  Vg(I,1),Vg(I,2)
    % second point  Vg(J,1),Vg(J,2)
    % but apparently not always (?)
    % get the angle with x-axis

    omega(ig)=atan2(Vg(I,2) - Vg(J,2),Vg(I,1) - Vg(J,1));
    
    % get the length
    cd(ig) = sqrt(md);
    
    % here we need something to project resp. rotate the vectices
    q= [cos(omega(ig)) sin(omega(ig)); -sin(omega(ig)) cos(omega(ig))];
    VgR = q*Vg';
    pcd(ig) = min([max(VgR(2,:))-min(VgR(2,:)), max(VgR(1,:))-min(VgR(1,:))]);
    % above, we probably won't need to check if the other set is shorter
    % but doesn't hurt

    % in case we want to get the coordiantes related to cd.
    %  v{ig}=[Vg(I,:) Vg(J,:)];
end
