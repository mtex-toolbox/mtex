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

% symmetry dependent settings
switch cs.id

  case 1, addReflector(-cs.axes(2));                          % 1
  case 2, addReflector(cs.axes(2));                           % -1
  case 3,                                                     % 2
    pm = 2*isPerp(cs(2).axis,zvector)-1;
    addReflector(rotate(sR.N,...
        rotation('axis',cs(2).axis,'angle',pm*90*degree)));  
  case 4, % nothing to do                                     % m
  case {5,6}, addReflector(rotate(sR.N(2),90*degree));        % -2m,222
  case {7,8} % nothing to do                                  % mm2,mmm
  case {9,10,11}                                              % 3,-3,32
    rot = rotation('axis',zvector,'angle',[30,-30]*degree);
    addReflector(rot .* sR.N(end-1:end));
  case 12, % nothing to do                                    % 3m
  case 13, addReflector(rotate(sR.N(2),30*degree));           % -3m
  case {14,16,17}, addReflector(rotate(sR.N(end),-45*degree)) % 4,4/m,422
  case 15, addReflector(rotate(sR.N(end),90*degree));         % -4 
  case 18, % nothing to do                                    % 4mm
  case 19, addReflector(rotate(sR.N(2),45*degree));           % -42m
  case 20, % nothing to do                                    % 4/mmm
  case {21,23}, addReflector(rotate(sR.N(end),-30*degree));   % 6, 6/m,
  case 22                                                     % -6
    rot = rotation('axis',zvector,'angle',[30,-30]*degree);
    addReflector(rot .* sR.N(end-1:end));
  case {24}, restrict2Sym(cs.Laue);                           % 622
  case {25,26,27}, % nothing to do                            % 6mm,-62m,6/mmm
  %case 28, restrict2Sym(cs.Laue); center = vector3d(1,1,1);   % 23
  case 28, addReflector(vector3d(-1,0,1));
  case 29, addReflector(rotate(sR.N(3),-45*degree))           % m-3   
  case 30, restrict2Sym(cs.Laue);                             % 432,
  case {31,32}, % nothing to do                               % -43m,m-3m
end
  
if ismember(cs.id,[2,10,15,29])
  warning('Not a topological correct colormap!');
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

% compute the color vector on the sphere
v = vector3d('rho',rho,'theta',radius.*pi);

% post processing of the color vector
% by default we have white at the z, black at the -z, red
% at x and green and blue at 120 and 240 degree accordingly

switch cs.id  % rotate red to the center  
  %case 1, rot = reflection(yvector); 
  case {2}
    rot = rotation(idquaternion);
  case {4} % m 2
    if ~isPerp(cs(2).axis,zvector) % m||c
      rot = reflection(yvector) * (-rotation('Euler',90*degree,90*degree,0));
    elseif ~isPerp(cs(2).axis,cs.axes(2))
      rot = rotation(idquaternion);
    else
      rot = rotation('axis',xvector,'angle',90*degree);
    end
      
  %case {7,8,13,14,16,17,18,19,20,26}, rot = reflection(yvector);
  %case 12
    %rot = rotation('axis',xvector,'angle',90*degree) * reflection(yvector);
  case vec2cell([1:6,9:12,15,21:25,27]), rot = reflection(yvector);  
  otherwise
    rot = rotation(idquaternion);
end

% change white and black
if ismember(cs.id,[1,3,5,6,9,11,13,15,21:24])
  rot = reflection(zvector) * rot;
end

% blue not correctly aligned: 3m (12), 

% post rotate the color
v = oM.colorPostRotation * rot * v;

% compute rgb values
rgb = ar2rgb(mod(v.rho./ 2 ./ pi,1),v.theta./pi,get_option(varargin,'grayValue',1));

% private functions
% -------------------------------------------------------------------------
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
% cs = symmetry('m-3m')
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

