function vecOut = vector3dnwse(nwseIn)
% find the vector3d corresponding to a NWSE map plot direction
% so you can do something like vector3d.x but instead vector3d.north
% nwseIn should be a character array or number


%% 1. find out where in the map (NWSE) points along X,-X,Y,-Y
%up to one of these is empty
dirX = getMTEXpref('xAxisDirection');
dirY = getMTEXpref('yAxisDirection');
dirZ = getMTEXpref('zAxisDirection');

% UpDown outputs {1 2} {'outOfPlane','intoPlane'};
% NWSE outputs {1 2 3 4} from {'east','north','west','south'}

if ~isempty(dirZ)
    vZ = UpDown(dirZ);
else
    try
        % if Z points out, mod(vX,4) is smaller than mod(vY,4)
        vX = NWSE(dirX);
        vY = NWSE(dirY);
        if mod(vX,4) < mod(vY,4)
            vZ = 1;
        elseif mod(vX,4) > mod(vY,4) %otherwise Z must point in
            vZ = 2;
        end
    catch
        %either the coordinates are badly defined or something went wrong
        error('vector3dnwse: which way is Z pointing?');
    end
end

if ~isempty(dirX)
    vX = NWSE(dirX);
else
    try
        vY = NWSE(dirY);
        if vZ == 1  % Z points out, so X < Y
            vX = checkmod(mod(vY-1,4));
        elseif vZ == 2 %otherwise Z points in so X > Y
            vX = checkmod(mod(vY+1,4));
        end
        if vX==0 %mod(0,4) and mod(4,4) both to zero but we don't want this
            vX=4;
        end
    catch
        %either the coordinates are badly defined or something went wrong
        error('vector3dnwse: which way is X pointing?');
    end
end

if ~isempty(dirY)
    vY = NWSE(dirY);
else
    try
        if vZ == 1 % Z points out, so X < Y
            vY = checkmod(mod(vX+1,4));
        elseif vZ == 2 %otherwise Z points in so X > Y
            vY = checkmod(mod(vX-1,4));
        end
    catch
        %either the coordinates are badly defined or something went wrong
        error('vector3dnwse: which way is Y pointing?');
    end
end

vXminus = checkmod(mod(vX+2,4));
vYminus = checkmod(mod(vY+2,4));

%% 2. output a vector3d(+-XY) according to the input map direction (NWSE)
vList = [vX; vXminus; vY; vYminus];
vPos = find(vList==NWSE(nwseIn));

switch vPos
    case 1
        vecOut = vector3d.X;
    case 2
        vecOut = -vector3d.X;
    case 3
        vecOut = vector3d.Y;
    case 4
        vecOut = -vector3d.Y;
end


    function [vOut] = checkmod(vIn)
    %mod(0,4) and mod(4,4) both output zero but we actually want 4
        if vIn==0
            vOut=4;
        else
            vOut=vIn;
        end
    end

end


