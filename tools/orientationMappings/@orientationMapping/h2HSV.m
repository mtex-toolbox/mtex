function rgb = h2HSV(oM,h,varargin)
% converts crystal directions to rgb values
%
% The priciple idea is to take the fundamental sector, apply white to the
% center and red, blue and green to the vertices. This works well if all
% the edges of the fundamental sector are reflections, i.e. for for m, mm2, 
% mmm, 3m, 4mm, 4/mmm, 6mm, -62m, 6/mmm, -43m, m-3m.
% In almost all other cases the fundamental sector can be divided by an
% additional reflection into two subsectors which are colored one with
% white and one with black center.
% There are three cases, -1, -3, -4, where this does not work. Actually one
% can show that in this cases it is impossible to have a smooth one to one
% relation between the color space and the fundamental sector.
  
cs = oM.CS1;

% region to be colored
sR = cs.fundamentalSector;

% project to fundamental region
h_sR = h.project2FundamentalRegion(cs);
h = h_sR;

% this should become white if not stated differently
center = sR.center;

rot = rotation(idquaternion);
alpha = 0;

if ismember(cs.id,[2,18,26])
  warning('Not a topological correct colormap! Green to blue colorjumps possible');
end

% symmetry dependent settings
switch cs.id

  case 1, addReflector(cs.axes(2));                          % 1
  case 2, addReflector(cs.axes(2));                          % -1
  case {3,6,9},                                              % 211, 121, 112
    pm = 1-2*isPerp(cs(2).axis,zvector);
    addReflector(rotate(sR.N,...
        rotation('axis',cs(2).axis,'angle',pm*90*degree)));
      if cs.id == 6, black2white;end
  case 4, green2white; alpha = 0.3;                          % m11
  %case 5, addReflector(cross(sR.N(1),sR.N(2)));             % 2/m11, 112/m
  case 7, alpha = 0.3;                                       % 1m1
  %case 8, addReflector(-cross(sR.N(1),sR.N(2)));        % 12/m1
  case 10, rot = rotation('Euler',270*degree,90*degree,180*degree); % 11m
  case {5,8,11,27,35} % 2/m, 4/m, 6/m
    mir = cs.isImproper & cs.angle>pi-1e-4;
    center = cs(mir).axis;    
    alpha = 0.3;
    if cs.id == 5                                             % 2/m11
      rot = rotation('Euler',30*degree,90*degree,0*degree);
    elseif cs.id == 8
      rot = idquaternion;
    else
      rot = rotation('Euler',270*degree,90*degree,180*degree);
    end
  case 12, addReflector(rotate(sR.N(2),-90*degree));        % -2m,222
  %case 15, alpha = 0.3; %mm2
  case 17                                                      % 3
    r = rotation('axis',zvector,'angle',[30,-30]*degree);
    addReflector(r .* sR.N(end-1:end));
    rot = rotation('axis',xvector,'angle',...
      -90*degree-3*mod(round(cs.axes(1).rho/degree),60)*degree);
  case 18                                                       %-3
    r = rotation('axis',zvector,'angle',[30,-30]*degree);
    addReflector(r .* sR.N(end-1:end));
%    blue2green;
  case {19,22}                                           % 3,-3,32
    r = rotation('axis',zvector,'angle',[30,-30]*degree);
    addReflector(r .* sR.N(end-1:end));
    %rot = rotation('axis',xvector,'angle',90*degree+3*cs.axes(1).rho);
    %rot = rotation('axis',xvector,'angle',180*degree);
  %case 12, % nothing to do                                    % 3m
  case 20, green2white;                                        %3m1
  case 21, addReflector(rotate(sR.N(2),30*degree));       % -31m
  case 24, addReflector(rotate(sR.N(2),30*degree));       % -3m1
    black2white; blue2green
  case {25,28}, addReflector(rotate(sR.N(end),-45*degree)) % 4,4/m,422
  case 26, addReflector(rotate(sR.N(end),-90*degree));         % -4 
  
  case 29, % nothing to do                                    % 4mm
  case 30, addReflector(rotate(sR.N(2),45*degree));           % -42m
  case 31, addReflector(-rotate(sR.N(2),45*degree));           % -4m2
  case 32, % nothing to do                                    % 4/mmm
  case 33,                                                    % 6
     addReflector(rotate(sR.N(end),-30*degree));
     blue2green;
     black2white;
  case 34                                                     % -6
    r = rotation('axis',zvector,'angle',[30,-30]*degree);
    addReflector(r .* sR.N(end-1:end));
  
  case {36}                                                % 6/m, 622
    addReflector(rotate(sR.N(end),-30*degree));
    blue2green;
    black2white;
  case {37,40}                                                % 6mm,-62m,6/mmm
    if mod(round(cs.axes(1).rho/degree),60)==30, blue2green; end
  case 39,                                                    % -6m2
    %green2white;
    %if mod(round(cs.axes(1).rho/degree),60)==30, blue2green; end    
  case 41, addReflector(vector3d(-1,0,1));                    % 23
  %case 42, addReflector(rotate(sR.N(3),-45*degree))           % m-3
  case 42, center = vector3d(1,1,1);
  case 43, restrict2Sym(cs.Laue);                             % 432,
  case {44,45}, % nothing to do                               % -43m,m-3m
end
  
% compute angle of the points "sh" relative to the center point "center"
% this should be between 0 and 1
[radius,rho] = polarCoordinates(sR,h,center);

% which are white
whiteOrBlack = h_sR == h;

% white center
radius(whiteOrBlack) = 0.5+radius(whiteOrBlack)./2;

% black center
radius(~whiteOrBlack) = (1-radius(~whiteOrBlack))./2;

% stretch colors 
radius = radius*(1+alpha)-alpha;

% compute the color vector on the sphere
v = vector3d('rho',rho,'theta',radius.*pi);

% post processing of the color vector
% by default we have white at the z, black at the -z, red
% at x and green and blue at 120 and 240 degree accordingly

% post rotate the color
v = oM.colorPostRotation * rot * v;

% compute rgb values
rgb = ar2rgb(mod(v.rho./ 2 ./ pi,1),v.theta./pi,get_option(varargin,'grayValue',1));

% private functions
% -------------------------------------------------------------------------

  function green2white, rot = rot * rotation('axis',xvector,'angle',90*degree); end

% switch white and black
  function blue2green, rot = rot * reflection(yvector); end

% switch white and black
  function black2white, rot = reflection(zvector) * rot; end

  function addReflector(refl)
    % reduce fundamental sector for black-white colorcoding
    
    sR.N = [sR.N(:);refl(:)]; 
    sR.alpha = [sR.alpha(:);zeros(length(refl),1)];
     
    % copy to the reduced sector
    for i = 1:length(refl)
      ind = dot(h_sR,refl(i))<1e-5;
      h(ind) = reflection(refl(i)) * h(ind);      
    end
    center = sR.center;
  end

  function restrict2Sym(sym)
    sR = sym.fundamentalSector;
    h = h_sR.project2FundamentalRegion(sym);
    center = sR.center;
  end

end

% some testing code
% cs = crystalSymmetry('m-3m')
% h = plotS2Grid(cs.fundamentalSector)
% rgb = h2HSV(h,cs);
% surf(h,rgb)

% ---------------------------------------------------------------------
% compute rgb values from angle and radius
% ---------------------------------------------------------------------
function rgb = ar2rgb(omega,radius,grayValue)


L = (radius - 0.5) .* grayValue(:) + 0.5;

S = grayValue(:) .* (1-abs(2*radius-1)) ./ (1-abs(2*L-1));
S(isnan(S))=0;

[h,s,v] = hsl2hsv(omega,S,L);

% the following lines correct for small yellow and cyan range in normal hsv
% space
z = linspace(0,1,1000);

r = 0;f = 0.5 + exp(- 200.*(mod(z-r+0.5,1)-0.5).^2);
b = 0.6666;f = f + exp(- 200.*(mod(z-b+0.5,1)-0.5).^2);
g = 0.3333;f = f + exp(- 200.*(mod(z-g+0.5,1)-0.5).^2);
% some testing code for this correctiom
%

f = f./sum(f);
f = cumsum(f);
h = interp1(z,f,h);

rgb = reshape(hsv2rgb(h,s,v),[],3);

end

