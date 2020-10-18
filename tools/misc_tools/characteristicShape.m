function  [csAngle, csRadius] = characteristicShape(bc,bp,varargin)
% Derive the characteristic shape from a boundary trend distribution given
% in polar coordinates
%
% Input:
%  bc       - azimuth angle / bin center
%  bp       - radius / bin population
%
% Output:
%  csAngle  - azimuth angle of characteristic shape
%  csRadius - radius of characteristic shape
%
% Option
%  xy       - output in Cartesian coordiantes instead of polar coordiantes
%             (note that in this case you need to ensure the plotting ref.
%             frame to be identical with mtex)
%

bc=reshape(bc,[],1);
bp=reshape(bp,[],1);

% assume input comes from calcBoundaryTDF?
if bp(1)==bp(end)
    bp(end)= [];
    bc(end)=[];
end

% make x,y coordiantes
xy=[cos(bc).*bp sin(bc).*bp];
xy = cumsum(xy);
% normalize to pathlength
xy = xy./max([max(xy(:,1)) max(xy(:,2))]);
% center y and x
xy(:,2)=xy(:,2)+(abs(min(xy(:,2)))-abs(max(xy(:,2))))/2;
xy(:,1)=xy(:,1)+(abs(min(xy(:,1)))-abs(max(xy(:,1))))/2;
% normalize to area 1
xy=xy./sqrt(polyarea(xy(:,1),xy(:,2)));

if check_option(varargin,'xy')
csAngle  = [xy(:,1); xy(1,1)];
csRadius = [xy(:,2); xy(1,2)];
else
% radii of cshape - convert back to polar------------------------------
csRadius = sqrt(xy(:,2).^2+xy(:,1).^2);
csAngle = atan2(xy(:,2),xy(:,1)); %not sure yet why it shouldn't be bc?

csAngle(end+1) =  csAngle(1);
csRadius(end+1) = csRadius(1);
end
end