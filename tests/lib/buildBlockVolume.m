function [ebsd,numTrue] = buildBlockVolume(cs,sz,dxyz)
% five blocks of planted orientation and a notIndexed corner

ang = zeros(sz);
ang(7:end,1:5,:) = 10;
ang(7:end,6:end,1:5) = 20;
ang(7:end,6:end,6:end) = 30;
ang(10:11,2,2) = 35;
rot = reshape(rotation.byAxisAngle(zvector,ang(:)*degree),sz);

phaseId = 2*ones(sz);
phaseId(1:3,1:3,1:3) = 1;

numTrue = [prod(sz(1:3))/2-27; 27; 6*5*8-2; 2; 6*5*5; 6*5*3];
ebsd = EBSD3square([],rot,phaseId,[0;1],{'notIndexed',cs},dxyz);

end
