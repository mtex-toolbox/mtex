% create bitmap of HEALPix projection onto the plane
%
% OUT = HealpixPlaneProjBmp(n, A, n_x, n_y, emval)
% Parameters
% n   : resolution of the grid (N_side)
% A   : samples in HEALPix nested index
% n_x : number of pixel on plane along the axis x
% n_y : number of pixel on plane along the axis y
% emval : value for empty area

function OUT = HealpixPlaneProjBmp(n, A, n_x, n_y, emval)

if nargin ~= 5
    OUT = zeros(n_x, n_y);
else
    OUT = ones(n_x, n_y) * emval;
end

for iy = 1:n_y
    y = pi * (iy - 1) / n_y - pi / 2;
    for ix = 1:n_x
        x = 2 * pi * (ix - 1) / n_x;
        % correct distortion on the polar caps
        [ox, oy] = HealpixPlanePoleDistort(x, y);
        if ox < 0
            % out of domain
            continue
        end
        % get projection coordinate on the plane
        [i, j] = HealpixProjectionOntoPlane(n, ox, oy);
        
        % get the patch class of the point
        [class, INFO] = HealpixSelectPatchClass(n, i, j);

        switch class
            case 'o'
                [C, V1, V2, V3, V4] = HealpixGetPatchVertexCoordsO(n, i, j, INFO);
                [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRectangle(C(1), C(2));
            case 'r'
                [C, V1, V2, V3, V4] = HealpixGetPatchVertexCoordsR(n, i, j, INFO);
                [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRectangle(C(1), C(2));
            case 't'
                [C, V1, V2, V3, V4] = HealpixGetPatchVertexCoordsT(n, i, j, INFO);
                [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRectangle(C(1), C(2));
            case 'p'
                [C, V1, V2, V3, V4] = HealpixGetPatchVertexCoordsP(n, i, j, INFO);
                [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRhombus(C(1), C(2));
            case 'e'
                [C, V1, V2, V3, V4] = HealpixGetPatchVertexCoordsE(n, i, j);
                [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRhombus(C(1), C(2));
            case 'b'
                [C, V1, V2, V3, V4] = HealpixGetPatchVertexCoordsB(n, i, j, INFO);
                [w1, w2, w3, w4] = HealpixGetPatchVertexWeightsRhombus(C(1), C(2));
            otherwise
                w1 = 0;
                w2 = 0;
                w3 = 0;
                w4 = 0;                
        end

        if class ~= 'v'
%        if w1 ~= 0 || w2 ~= 0 || w3 ~= 0 || w4 ~= 0 
            c1 = A(1 + HealpixNestedIndexInv(n, V1(1), V1(2)));
            c2 = A(1 + HealpixNestedIndexInv(n, V2(1), V2(2)));
            c3 = A(1 + HealpixNestedIndexInv(n, V3(1), V3(2)));
            c4 = A(1 + HealpixNestedIndexInv(n, V4(1), V4(2)));
        else
            c1 = 0;
            c2 = 0;
            c3 = 0;
            c4 = 0;
        end 
        
        % weights are area of parallelogram which is located on diagonal of each sampling point
        OUT(ix, iy) = sum([w1 w2 w3 w4] .* [c1 c2 c3 c4]);
%        sum([w1 w2 w3 w4])
    end
end
