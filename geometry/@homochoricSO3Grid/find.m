function [id,dist] = find(S3G,ori,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
% Syntax
%   % find the closes point
%   [ind,dist] = find(SO3G,ori)
%
%   % find points with a radius
%   [ind,dist] = find(SO3G,ori,radius)
%
%   % find cube corners
%   cubeInd = find(SO3G,ori,'cube')
%
% Input
%  SO3G   - @homochoricSO3Grid
%  ori    - @orientation
%  radius - double
%
% Output
%  ind  - index of the closes grid point
%  cubeInd - Nx8 list of indeces of the cube corners containing ori
%  dist - misorientation angle
%

% project oris to fundamental Region
ori = project2FundamentalRegion(ori, S3G.CS, S3G.SS);

% translate input (ori) into cubochoric coordinates
xyz = quat2cube(ori);

% N intervals of length hres along each edge of the cube
N = round(2 * pi / S3G.res);
hres = pi^(2/3) / N;

if nargin == 2 % closest point
    
    % calculate grid index along each axis of the cube
    % let the grid have N points along each axis
    % then xyz/hres takes values in [-N/2,N/2]
    % 0 is included in the grid iff N is odd
    % so xyz/hres+N/2-1/2 takes values in -1/2,...,N-1/2
    % after rounding this should yield values in 0,...,N-1
    sub  = mod(round(xyz/hres + N/2 - 0.5),N) + 1;    % [ix, iy, iz] each from 1 to N
    id = sub2ind(S3G,sub(:,1),sub(:,2),sub(:,3));
    
    if nargout == 2
        dist = zeros(size(id));     % initialize distances
        dist(id>0) = angle(ori.subSet(id>0), S3G.subSet(id(id>0)), 'noSymmetry');
    end
    
    % project those not beeing in fR again --> Quaternion Projected
    if any(id==0)
        
        % take outside grid points
        subxyz = hres * (sub(id==0,:) - (N+1)/2);
        
        % and project them back into the fundamental region
        q2 = project2FundamentalRegion(cube2quat(subxyz),S3G.CS,S3G.SS);
        
        % find closest grid point
        xyz2 = quat2cube(q2);
        sub2 = mod(round(xyz2/hres + N/2 - 0.5),N) + 1;
        
        % insert eventually new found neighbors on grid into id
        id2 = sub2ind(S3G,sub2(:,1),sub2(:,2),sub2(:,3));
        
        % get indice of zeros in id
        iszero = find(~id);
        
        % compute distances where id is zero and id2 isnt zero 
        % (new found valid neighbors)
        if nargout == 2
            dist(iszero(id2>0)) = angle(ori.subSet(iszero(id2>0)), S3G.subSet(id2(id2>0)));
        end
        
        % plug in new found indice
        id(~id) = id2;
        
    end
    
    % if still not in fR, then search for best neighbor (of 8 surrounding)
    % notice that at least one of those 8 neighbors will lie in S3G
    if any(id==0)
        
        % get indice of surrounding vertices of the whole grid for those points
        % who dont have a valid nearest neighbor yet
        % for more info see docu of getS3Gvertices
        idx = getS3GVertices(S3G, xyz(id==0,:));
        
        % initialize set of nearest neighbors all as invalid
        S3Gvertices = rotation.nan(sum(id==0), 8);
        
        % and only overwrite this ones where idx > 0 (valid neighbor found)
        S3Gvertices(idx>0) = S3G.subSet(idx(idx>0));
        
        % calculate distances ...
        d = angle(repmat(ori(id==0), 1, 8), S3Gvertices, 'noSymmetry');
        
        % ... to find the nearest point
        [dmin, idmin] = min(d, [], 2);
                
        % overwrite the distance, if 2 outputs
        if nargout == 2
            dist(id==0) = dmin;
        end
        
        % overwrite new found indice
        % all indice now have a valid value ~= 0 (>= 1 of 8 neighbors in fR)
        id(id==0) = idx(sub2ind(size(idx), (1:sum(id==0))', idmin));
        
    end
    
    
elseif ischar(varargin{1}) % cube c
    
    % get indice of surrounding vertices of the whole grid for those points
    % who dont have a valid nearest neighbor yet
    % for more info see docu of getS3Gvertices
    id = getS3GVertices(S3G, xyz);
    
    % calculate coordinate-wise distances to the floor corner
    % (attained by rounding coordinates down to the grid)
    % care that it mathers if the grid is odd or even since we then have to
    % round towards multiples of hres or the same shifted by hres/2
    dist = mod((N+1)/2*hres+xyz,hres);
    
else % neighborhood
    
end

end