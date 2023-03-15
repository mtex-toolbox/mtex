function wB = weightedBurgersV(ebsd,varargin)
%
% Syntax
% 

wS = get_option(varargin,'windowSize',1);

wS = 3;
gX = ebsd.gradientX;
gY = ebsd.gradientY;

gX(abs(gX)>10*degree) = 0;
gY(abs(gY)>10*degree) = 0;

fX = repmat([-1 zeros(1,2*wS) 1],2+2*wS,1);
fY = fX.';

fT = abs(fX) + abs(fY);

wX = filter2(abs(fX),norm(gX)>0);
wY = filter2(abs(fY),norm(gY)>0);

wB = vector3d;
wB.x = filter2(fX,gX.x) + filter2(fY,gY.x);
wB.y = filter2(fX,gX.y) + filter2(fY,gY.y);
wB.z = filter2(fX,gX.z) + filter2(fY,gY.z);

wB = wB ./ (wX +wY);

nextAxis(1)
plot(ebsd,ebsd.orientations.angle)

nextAxis(2)
plot(ebsd,norm(wB))



end

function test

cs = crystalSymmetry;

% spatial coordinates
[opt.y,opt.x] = meshgrid(1:25,1:100);
opt.x = opt.x(:); opt.y = opt.y(:);

f = @(x,y) 20*degree + ...
  + 18*degree * (1+sign(x-0.6999)).*(1-x)/0.6 ...
  + 2*degree  * ((x+0.1*y)<0.2) ...
  + 3*degree  * sin((x-0.4+0.075)./0.3 .* 4*pi) .* (abs(x-0.4)<0.075);



ori = orientation('Euler',0,f(opt.x./max(opt.x),opt.y./max(opt.y)),0,cs);

ebsd = EBSD(ori,ones(numel(opt.x),1),{cs},opt,'unitCell',....
  calcUnitCell([opt.x,opt.y]));

ebsd = ebsd.gridify;

plot(ebsd,ebsd.orientations.angle)


if check_option(varargin,'Poussin')
  odf = unimodalODF(quaternion.id,'halfwidth',get_option(varargin,'Poussin'));

  ebsd.orientations = discreteSample(odf.components{1},numel(opt.x)) .* ori;
end

if check_option(varargin,'saltPepper')
  odf = uniformODF(cs);

  ind = discretesample(numel(opt.x),numel(opt.x) * get_option(varargin,'saltPepper'));
  ebsd.orientations(ind) = discreteSample(odf,numel(ind));
end



end

