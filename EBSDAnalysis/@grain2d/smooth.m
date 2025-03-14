function [grains,stablefraction] = smooth(grains,iter,ebsd,varargin)
% constrained laplacian smoothing of grain boundaries
% stopping criteria for smoothing iterations based on boundary ebsdId positions
%
% start excluding gb segments when they cross over to the wrong side of
% grains.boundary.ebsdId
%
% Input
%  grains - @grain2d
%  iter   - number of iterations (default: 1)
%
% Output
%  grains - @grain2d
%  stablefraction - scalar - fraction of boundary vertices that stopped
%  moving before the last smoothing iteration
%
% Options 
%  moveTriplePoints  - do not exclude triple/quadruple points from
%  smoothing (checked - ok with new smooth)
% % the options below have not been checked for compatibility with new smooth!
%  moveOuterBoundary - do not exclude outer boundary from smoothing
%  second_order, S2  - second order smoothing
%  rate              - default smoothing kernel
%  gauss             - Gaussian smoothing kernel
%  exp               - exponential smoothing kernel
%  umbrella          - umbrella smoothing kernel
%
%
% Versions
% 2024-07-23 - Created function based on mtex/grain2d/smooth
% 2024-07-23 - Replace for-loop with array indexing when excluding segments

if abs(dot(grains.N,zvector)) ~= 1
    % update this to rotate ebsd to plane as well and run smooth1
    [grains,rot] = rotate2Plane(grains);
    [ebsd] = rotate(ebsd,rot);
    [grains,stablefraction] = smooth1(grains,iter,ebsd,varargin);
    grains = inv(rot) * grains;

    return

end


if nargin < 2 || isempty(iter), iter = 1; end

% compute incidence matrix vertices - faces
I_VF = [grains.boundary.I_VF,grains.innerBoundary.I_VF];

% compute vertices adjacency matrix
A_V = I_VF * I_VF';
t = size(A_V,1);
numF = size(I_VF,2);
% do not consider triple points
if check_option(varargin,'moveTriplePoints')
    ignore = false(size(A_V,1),1);
else
    ignore = full(diag(A_V)) > 2;
end

% ignore outer boundary
if ~check_option(varargin,'moveOuterBoundary')
    ignore(grains.boundary.F(any(grains.boundary.grainId==0,2),:)) = true;
end

if check_option(varargin,{'second order','second_order','S','S2'})
    A_V = logical(A_V + A_V*A_V);
    A_V = A_V - diag(diag(A_V));
end

weight = get_flag(varargin,{'gauss','expotential','exp','umbrella','rate'},'rate');
lambda = get_option(varargin,weight,.5);


V = grains.allV.xyz; % 1 per vertex V
isNotZero = ~all(~isfinite(V) | V == 0,2) & ~ignore; %this is at the start, update as boundary Vs get excluded

%%%%% this is where the changed bit starts (wrt standard mtex/smooth)
ebsdIdPairs = [grains.boundary.ebsdId; grains.innerBoundary.ebsdId]; % 1 per segment F

% index me using I_VF -- each column is V belonging to 1 F
% so for segment f1
% [v1] = find(I_VF(f1,:));
%always 2 V per segment F but cellfun doesn't like uniformoutput bc the matrices
%are shaped wrong, so reshape stuff afterwards
VperF= cellfun(@find,mat2cell(I_VF,size(I_VF,1),ones(1,size(I_VF,2))),'UniformOutput',false); VperF=permute(cat(2,VperF{:}),[2 1]);

%initialise line segment intersections - this determines whether or not a gb segment may move or not
% all segments are allowed to move at the start.
% If the the gB segment line intersects the line drawn between the ebsd map
% points either size of the gB (ebsdIdPairs), it means that the boundary has
% not moved into the wrong part of the ebsd map and you can allow further
% smoothing.
tfIntersect=true(numF,1); % if tfIntsersect(i) == true, then allow V(i) to move

for l=1:iter

    %%%%% from orignal code
    if ~strcmpi(weight,'rate')
        [i,j] = find(A_V);
        d = sqrt(sum((V(i,:)-V(j,:)).^2,2)); % distance
        switch weight
            case 'umbrella'
                w = 1./(d);
                w(d==0) = 1;
            case 'gauss'
                w = exp(-(d./lambda).^2);
            case {'expotential','exp'}
                w = lambda*exp(-lambda*d);
        end

        A_V = sparse(i,j,w,t,t);
    end

    % take the mean over the neigbours
    Vt = A_V * V;

    m = sum(A_V,2);


    dV = V(isNotZero,:)-bsxfun(@rdivide,Vt(isNotZero,:),m(isNotZero,:));

    isZero = any(~isfinite(dV),2);
    dV(isZero,:) = 0;
    %%%%%%

    % update V - but save a copy VOld before updating
    VOld=V;
    V(isNotZero,:) = V(isNotZero,:) - lambda*dV;

    %find ebsdIdLines on either side of gB segments F
    %look through rows for any bad ebsdId points - 0 or other weird numbers
    badEbsdId = any((~(ebsdIdPairs) | isnan(ebsdIdPairs) |  isinf(ebsdIdPairs)),2);
    %can't draw line, probably a map edge, exclude me
    tfIntersect(badEbsdId) = false;

    e1 = ebsd(id2ind(ebsd,ebsdIdPairs(tfIntersect,:))).pos;
    ebsdIdLine = permute(cat(3,e1.x, e1.y), [2 3 1]);

    %2 Vs per F
    % test ebsdIdPairs against V
    % see warning just after the iter for-loop
    vS= cat(3,V(VperF(tfIntersect,1),1),V(VperF(tfIntersect,1),2)); % xy of segment starts
    vE= cat(3,V(VperF(tfIntersect,2),1),V(VperF(tfIntersect,2),2)); % xy of segment ends
    vLine = permute(cat(2,vS,vE),[2 3 1]); %handle dims
    %if these line segments intersect, this point may still move
    %if they don't intersect, this V shouldn't move anymore
    % only repopulate 'true' elements of tfFintersect
    tfIntersect(tfIntersect) = testIntersection(vLine,ebsdIdLine);

    % if the line segments don't intersect,
    % revert the vertex positions - don't update V
    % (just now we did VOld=V; before updating V(isNotZero,:) =
    % V(isNotZero,:) - lambda*dV;)
    vDontMove= unique(VperF(~tfIntersect)); % V might appear more than once
    V(vDontMove,:) = VOld(vDontMove,:);

    % stop moving these vertices in the future
    % update isNotZero
    isNotZero(vDontMove) = false;

end

% output grain vertices that stopped moving
stablefraction = numel(vDontMove)/t;

% update output
grains.allV = vector3d.byXYZ(V);

end


function tf = testIntersection(line1, line2)
% test whether or not two sets of finite length line segments intersect
%
% Inputs
% line1 = 2*2*n numeric matrix [startx starty; endx endy] * n lines
% line2 = another line / set of lines similar to line1
%
% Outputs
% tf = 1*n logical array, true if the nth line1 and line2 intersect, false if they don't (or it's another special
% case*)

% * if line1==line2 or any of the line lengths are 0
% (i.e. [startx starty] == [endx endy]), then tf returns
% false even if they intersect which is ok for us, this
% should never happen for gb segments which means something has
% probably gone wrong anyway and we shouldn't move it.
%
% References
% method from here:
% https://stackoverflow.com/questions/3838329/how-can-i-check-if-two-segments-intersect
% which references https://bryceboe.com/2006/10/23/line-segment-intersection-algorithm/
%translation of python code
% def ccw(A,B,C):
% return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)
%
% # Return true if line segments AB and CD intersect
% def intersect(A,B,C,D):
% return ccw(A,C,D) != ccw(B,C,D) and ccw(A,B,C) != ccw(A,B,D)
% end
%
% def ccw(A,B,C):

aa = permute(line1(1,:,:),[2 3 1]); %startpoint of line1, [x y] * n lines
bb = permute(line1(2,:,:),[2 3 1]); %endpoint of line1, [x y] * n lines
cc = permute(line2(1,:,:),[2 3 1]);  %startpoint of line2, [x y] * n lines
dd = permute(line2(2,:,:),[2 3 1]);  %endpoint of line2, [x y] * n lines
% use permute to get rid of leading 1* dimension

ccw = @(A,B,C) (C(2,:) - A(2,:)) .* (B(1,:)-A(1,:)) > (B(2,:)-A(2,:)) .* (C(1,:)-A(1,:));
tf = (ccw(aa,cc,dd) ~= ccw(bb,cc,dd)) & (ccw(aa,bb,cc) ~= ccw(aa,bb,dd));
tf=tf(:);
end
