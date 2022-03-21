classdef shape2d < grain2d
    properties

        Vs              % list of vertices
        rho            % radius of polar coords
        theta          % angle of polar coords
    end


    % 1) should be constructed from calcTDF / circdensity (density function from a set of lines)
    % characteristicshape
    % surfor, paror
    % 2) purpose: take advantage of grain functions (long axis direction, aspect ratio..)
    %
    % additional functions I will try to put here: measure of asymmetry
    % nice plotting wrapper (replacing plotTDF)

    methods

        function shape = shape2d(Vs)
            % list of vertices [x y]
            % construct a fake grain2d
            prop = struct('x',1,'y',1,'grainId',1);
            ebsd = EBSD(rotation.nan,1,{'Hallo'},prop);
            n = size(Vs,1);
            F = [(1:n).',[(2:n).';1]];
            I_DG = 1;
            I_FD = sparse(ones(size(F,1),1));
            A_Db = 1;
            shape = grain2d(ebsd,Vs,F,I_DG,I_FD,A_Db);

        end

    end

end
