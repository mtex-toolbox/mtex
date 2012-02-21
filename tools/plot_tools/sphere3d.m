function [Xout, Yout, Zout, Cmap] = sphere3d(Zin,theta_min,theta_max,...
                                    phi_min,phi_max,Rho,meshscale,varargin)
%
% SPHERE3D  Plots 3D data on a spherical surface.
% 
%  SPHERE3D(Zin,theta_min,theta_max,phi_min,phi_max,Rho,meshscale) 
%  plots the 3D profile Zin as a mesh plot on a spherical surface 
%  of radius Rho, between horizontal sweep angles theta_min and 
%  theta_max and vertical phi_min and phi_max, with mesh size 
%  determined by meshscale. 
% 
%  SPHERE3D(Zin,...,meshscale,plotspec) plots the 3D profile Zin 
%  with a plot type specification. If plotspec = 'surf' a standard
%  surface is plotted, whereas 'mesh', or 'meshc' will plot mesh,
%  or mesh with contour, respectively. A special contour is
%  plotted when plotspec = 'contour'. The default is mesh if not
%  specified.   
%
%  SPHERE3D(Zin,...,meshscale,interpspec) plots the 3D profile Zin
%  with the interpolation specification, interpspec, which can be 
%  one of 'spline', 'linear', 'nearest' or 'cubic'. The default  
%  interpolation is linear if not specified.     
%
%  SPHERE3D(Zin,...,meshscale,Zscale) plots the 3D profile Zin with 
%  the data scaling factor, Zscale. This allows you to scale the 
%  peaks and troughs of the data on the surface if the radius is
%  relatively large. Zscale larger than 1 magnifies the data
%  range correspondingly. Zscale defaults to 1 if not specified.
% 
%  [Xout,Yout,Zout,Cmap] = SPHERE3D(Zin,...) returns output values
%  corresponding to the Cartesian positions (Xout,Yout,Zout) with 
%  colour map, Cmap.         
% 
%% Syntax
%  sphere3D(Zin,theta_min,theta_max,phi_min,phi_max,Rho,meshscale)
%  sphere3D(Zin,theta_min,theta_max,phi_min,phi_max,Rho,meshscale,plotspec)
%  sphere3D(Zin,theta_min,theta_max,phi_min,phi_max,Rho,meshscale,interpspec)
%  sphere3D(Zin,theta_min,theta_max,phi_min,phi_max,Rho,meshscale,Zscale)
%  sphere3D(Zin,...,meshscale,plotspec,interpspec)
%  sphere3D(Zin,...,meshscale,plotspec,Zscale)
%  sphere3D(Zin,...,meshscale,interpspec,Zscale)
%  sphere3D(Zin,...,meshscale,plotspec,interpspec,Zscale)
%  [Xout,Yout,Zout,Cmap] = sphere3D(Zin,...)
%  
%% Input
%  Zin         input magnitude profiles where each row in Zin is 
%  assumed to represent the horizontal sweep information 
%  between theta_min and theta_max at a given vertical 
%  sweep angle phi on the sphere. Alternatively, each 
%  column represents the data gathered between top to
%  bottom of the sphere at given angle theta.
%  
%  Zin is a (M x N) matrix, where M and N are not 
%  necessarily equal. If M is not equal to N then the
%  data are interpolated to make them equal. The final
%  size is determined by the larger value of (M,N),
%  and meshscale if different from 1.
% 
%  The N columns of Zin are assumed to be equally
%  spaced measurements starting from top (phi_max) to 
%  bottom of the sphere (phi_min), and at angle theta_min  
%  and so on, to the last column at theta_max. The
%  vertical axis of the sphere is assumed to be 
%  parallel to the columns in the data.
%
%  Zin(1,1) corresponds to (theta_min,phi_max) and 
%  Zin(M,1) corresponds to (theta_min,phi_min).
%  Zin(1,N) corresponds to (theta_max,phi_max) and 
%  Zin(M,N) corresponds to (theta_max,phi_min).  
%  Theta increases in the anticlockwise direction 
%  looking from the top of the sphere, while phi 
%  increases from lower hemisphere to the upper.
% 
%  theta_min   the lower value in radians of the angular range 
%  (horizontal sweep) over which the data is defined. 
%  Theta_min is a scalar quantity.
% 
%  theta_max   the upper value in radians of the angular range 
%  (horizontal sweep) over which the data is defined. 
%  Theta_max is a scalar quantity.
%
%  The difference between theta_max and theta_min
%  should be no more than 2pi.
% 
%  phi_min     the lower value in radians of the angular range 
%  (vertical sweep) over which the data is defined. 
%  Phi_min is a scalar quantity.
% 
%  phi_max     the upper value in radians of the angular range 
%  (vertical sweep) over which the data is defined. 
%  Phi_max is a scalar quantity.
%
%  The difference between phi_max and phi_min should
%  be no more than pi.
% 
%  Rho         the radius of the cylinder. Rho is a scalar
%  quantity. See comments on Zscale for connection  
%  between Rho and Zscale.
% 
%  meshscale   a scalar that determines the size of the squares 
%  on the mesh or surf plots, and takes on integer or
%  non-integer values greater than 0.
%
%  If meshscale = 1, the mesh remains unchanged relative
%  to the input grid. If meshscale = 2.15, say, the size  
%  of the squares is increased by this factor with
%  a consequential decrease in the dimensions of Xout,  
%  Yout and Zout by the same factor.
%
%  If meshscale is less than 1, a decrease in the mesh
%  squares will follow with a consequential increase 
%  in the dimensions of Xout, Yout and Zout by 1/meshscale.                                          
% 
%  plotspec    = 'surf'  produces a surface plot.
%  = 'mesh'  produces a mesh plot.
%  = 'meshc'  produces a mesh plot with countour in 
%  the X-Y plane.
%  = 'contour'  produces a transparent 2D contour plot
%  on the curved surface of the cylinder.
%  = 'off' disengages plot function.
% 
%  interpspec  = 'linear'  bilinear interpolation on Zin.
%  = 'spline'  spline interpolation on Zin.
%  = 'nearest'  nearest neighbour interpolation on Zin.
%  = 'cubic'  bicubic interpolation on Zin.
%
%  If Zin is a square matrix and meshscale = 1, no
%  interpolation is carried out.
% 
%  Zscale      a scalar that allows the user to scale the peaks and
%  troughs of the data so that it is more visible, 
%  especially when the radius of the sphere is large 
%  in comparison to the swings in the data.
%
%  When Zscale = 1, no data scaling occurs and the object 
%  appears in its true shape. 
%
%  When Zscale is not 1, the maximum and minimum
%  radial values are rescaled and may become negative.
%  When this occurs Zscale defaults to the maximum 
%  scaling factor possible and a warning is given.  
%  No action is required by the user.
%
%  When Zscale is small in relation to the radius, a 
%  smooth spherical surface is produced with radius Rho.
%  When used in conjunction with surf plot, the result
%  gives the impression of a filled contour plot.
% 
%% Output
%  Zout        output magnitude profiles defined by Zin at
%  positions (Xout,Yout). 
%  
%  Zout is square with dimensions determined by the 
%  maximum dimension of the input matrix Zin. The 
%  dimensions of Zout are antipodal or enlarged by meshscale.                      
% 
%  Xout        output X-positions corresponding to polar positions
%  (rho,theta). Xout is square with dimensions  
%  determined by the maximum dimension of the input 
%  matrix Zin. The dimensions of Xout are antipodal or 
%  enlarged by meshscale.
% 
%  Yout        output Y-positions corresponding to polar positions
%  (rho,theta). Yout is square with dimensions  
%  determined by the maximum dimension of the input 
%  matrix Zin. The dimensions of Yout are antipodal or 
%  enlarged by meshscale.
%
%  Cmap        colour mapping associated with (Xout,Yout,Zout). The
%  dimension of Cmap is square and similar in size to
%  Xout, Yout and Zout.
%
%  Written by JM DeFreitas, QinetiQ Ltd, Winfrith Technology
%  Centre, Dorchester DT2 8XJ, UK. jdefreitas@qinetiq.com.
%
%  Released 27 September 2005. (Beta Release).
%
%  Terms and Conditions of Use
% 
%  1.	This function is made available to Matlab� users under the 
%  terms and conditions set out in the Matlab Exchange by 
%  The Mathworks, Inc.
%  2.	Where the use of SPHERE3D is to be cited, the following is recommended:
%  J M De Freitas. �SPHERE3D: A Matlab� Function to Plot 3-Dimensional 
%  Data on a Spherical Surface�. 
%  QinetiQ Ltd, Winfrith Technology Centre, Winfrith, 
%  Dorchester DT2 8XJ. UK. 15 September 2005. 
%  3.	No offer of warranty is made or implied by the author and 
%  use of this work means that the user has agreed to take full 
%  responsibility for its use.
%
%  
if (nargin < 7)
    disp('SPHERE3D Error: Too few input arguments.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
elseif (nargin > 10)
    disp('SPHERE3D Error: Too many input arguments.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end

[p,q] = size(theta_min);
if (((p ~= 1)|(q ~= 1))|~isreal(theta_min))|ischar(theta_min)
    disp('SPHERE3D Error: theta_min must be scalar and real.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end
[p,q] = size(theta_max);
if (((p ~= 1)|(q ~= 1))|~isreal(theta_max))|ischar(theta_max)
    disp('SPHERE3D Error: theta_max must be scalar and real.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end
if theta_max <= theta_min
    disp('SPHERE3D Error: theta_max less than or equal theta_min.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end
if abs(theta_max - theta_min) > 2*pi
    disp('SPHERE3D Error: range of theta greater than 2pi.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end

[p,q] = size(phi_min);
if (((p ~= 1)|(q ~= 1))|~isreal(phi_min))|ischar(phi_min)
    disp('SPHERE3D Error: phi_min must be scalar and real.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end
[p,q] = size(phi_max);
if (((p ~= 1)|(q ~= 1))|~isreal(phi_max))|ischar(phi_max)
    disp('SPHERE3D Error: phi_max must be scalar and real.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end
if phi_max <= phi_min
    disp('SPHERE3D Error: phi_max less than or equal phi_min.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end
if abs(phi_max - phi_min) > pi
    disp('SPHERE3D Error: range of phi greater than pi.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end

[p,q] = size(Rho);
if (((p ~= 1)|(q ~= 1))|~isreal(Rho))|(ischar(Rho)|Rho < 0)
    disp('SPHERE3D Error: Rho must be scalar, positive and real.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end

[p,q] = size(meshscale);
if (((p ~= 1)|(q ~= 1))|~isreal(meshscale))|ischar(meshscale)
    disp('SPHERE3D Warning: mesh scale must be scalar and real.');
    meshscale = 1;
end
if (meshscale <= 0)
    disp('SPHERE3D Warning: mesh scale must be scalar and positive.');
    meshscale = 1;
end

% Set up default plot and interpolation specifications.
str1 = 'mesh';
str2 = 'linear';
str3 = 1.0;
if length(varargin) == 3
% Sort out plot,interpolation and data scaling specification if three variables given.   
    str1 = [varargin{1}(:)]';
    str2 = [varargin{2}(:)]';
    str3 = [varargin{3}(:)]';
    g1 = (~isequal(str1,'mesh')&~isequal(str1,'surf'))&~isequal(str1,'off');
    g2 = (~isequal(str1,'meshc'));
    g5 = (~isequal(str1,'contour'));
    g3 = (~isequal(str2,'cubic')&~isequal(str2,'linear'));
    g4 = (~isequal(str2,'spline')&~isequal(str2,'nearest'));
    g6 = ~isnumeric(str3);
    if (g1&g2&g5)
        disp('SPHERE3D Warning: Incorrect plot specification. Default to mesh plot.');
        str1 = 'mesh';
    end
    if (g3&g4)
        disp('SPHERE3D Warning: Incorrect interpolation specification.'); 
        disp('Default to linear interpolation.');
        str2 = 'linear';
    end  
    if (g6)
        disp('SPHERE3D Warning: Incorrect data scaling factor.'); 
        disp('Default to Zscale = 1.');
        str3 = 1.0;
    end  
elseif length(varargin) == 2
% Sort out plot,interpolation or data scaling specification if two variables given.   
    str1 = [varargin{1}(:)]';
    str2 = [varargin{2}(:)]';
    g1 = (~isequal(str1,'mesh')&~isequal(str1,'surf'))&~isequal(str1,'off');
    g2 = (~isequal(str1,'meshc'));
    g3 = (~isequal(str1,'contour'));
    g4 = (~isequal(str1,'cubic')&~isequal(str1,'linear'));
    g5 = (~isequal(str1,'spline')&~isequal(str1,'nearest'));  
    if (g1&g2&g3&g4&g5)
        disp('SPHERE3D Warning: Incorrect plot or interpolation specification.'); 
        disp('Default to mesh plot and linear interpolation.');
        str1 = 'mesh';
        str2 = 'linear';
    end   
    g6 = (~isequal(str2,'cubic')&~isequal(str2,'linear'));
    g7 = (~isequal(str2,'spline')&~isequal(str2,'nearest'));  
    g8 = ~isnumeric(str2);
    if (g6&g7&g8)
        disp('SPHERE3D Warning: Incorrect interpolation specification or data scaling factor.'); 
        disp('Default to linear interpolation and Zscale = 1.');
        str2 = 'linear';
        str3 = 1.0;
    end  
    temp2 = str2;
    if isequal(str1,'cubic')
        str2 = str1;
        str1 = 'mesh';
    elseif isequal(str1,'linear')
        str2 = str1;
        str1 = 'mesh';
    elseif isequal(str1,'spline')
        str2 = str1;
        str1 = 'mesh';
    elseif isequal(str1,'nearest')
        str2 = str1;
        str1 = 'mesh';   
    end 
    if isnumeric(temp2)
        str3 = temp2;
        if ~(g1&g2&g3)
            str2 = 'linear';
        else
            str1 = 'mesh';
        end
    end

elseif length(varargin) == 1
% Sort out plot, interpolation specification or data scaling factor from single variable input.    
    str1 = [varargin{1}(:)]';
    g1 = (~isequal(str1,'mesh')&~isequal(str1,'surf'))&~isequal(str1,'off');
    g2 = (~isequal(str1,'meshc'));
    g5 = (~isequal(str1,'contour'));
    g3 = (~isequal(str1,'cubic')&~isequal(str1,'linear'));
    g4 = (~isequal(str1,'spline')&~isequal(str1,'nearest'));  
    g6 = ~isnumeric(str1);
    if (g1&g2)&(g3&g4&g5&g6)
        disp('SPHERE3D Error: Incorrect plot,interpolation specification or data scaling factor.');
        Xout = []; Yout = []; Zout = []; Cmap = [];
        return
    elseif isequal(str1,'cubic')
        str2 = str1;
        str1 = 'mesh';
    elseif isequal(str1,'linear')
        str2 = str1;
        str1 = 'mesh';
    elseif isequal(str1,'spline')
        str2 = str1;
        str1 = 'mesh';
    elseif isequal(str1,'nearest')
        str2 = str1;
        str1 = 'mesh';
    elseif isequal(str1,'off')
        str2 = 'linear'; 
    elseif isnumeric(str1)
        str3 = str1;
        str1 = 'mesh';
    end 
end;

% Check if data scaling factor is acceptable.
Zscale = str3;
[p,q] = size(Zscale);
if (((p ~= 1)|(q ~= 1))|~isreal(Zscale))|(ischar(Zscale)|Zscale < 0)
    disp('SPHERE3D Error: Zscale must be scalar, positive and real.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return
end

% Check if dimensions of input data are acceptable.
[r,c] = size(Zin');
if (r < 5)&(c < 5)
    disp('SPHERE3D Error: Input matrix dimensions must be greater than (4 x 4).');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return    
end

% Check if input data has two rows or columns or less.
if (r < 3)|(c < 3)
    disp('SPHERE3D Error: One or more input matrix dimensions too small.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return    
end

% Setup input magnitude matrix. 
Zin = flipud(Zin);
[r,c] = size(Zin);

% Check if meshscale is compatible with dimensions of input data.
scalefactor = round(max(r,c)/meshscale);
if scalefactor < 3
    disp('SPHERE3D Error: mesh scale incompatible with dimensions of input data.');
    Xout = []; Yout = []; Zout = []; Cmap = [];
    return    
end

% Set up meshgrid corresponding to larger matrix dimension of Zin
% for interpolation if required.
n = meshscale;
if r > c
    L = r;
    L2 = fix(L/n)*n;
    step = r/(c-1);
    [X1,Y1] = meshgrid(0:step:r,1:r);
    if n < 1
        [X,Y] = meshgrid(0:n:(L2-n),0:n:(L2-n));
    else
        [X,Y] = meshgrid(1:n:L2,1:n:L2); 
    end
    T = interp2(X1,Y1,Zin,X,Y,str2);
elseif c > r
    L = c;
    L2 = fix(L/n)*n;
    step = c/(r-1);
    [X1,Y1] = meshgrid(1:c,0:step:c);
    if n < 1
        [X,Y] = meshgrid(0:n:(L2-n),0:n:(L2-n));
    else
        [X,Y] = meshgrid(1:n:L2,1:n:L2); 
    end
    T = interp2(X1,Y1,Zin,X,Y,str2);
else
    L = r;
    L2 = fix(L/n)*n;
    [X1,Y1] = meshgrid(1:r,1:r);
    if n < 1
        [X,Y] = meshgrid(0:n:(L2-n),0:n:(L2-n));
    else
        [X,Y] = meshgrid(1:n:L2,1:n:L2); 
    end
    T = interp2(X1,Y1,Zin,X,Y,str2);
end

[p,q] = size(T);
L2 = max(p,q);

% Set up angles theta
angl = theta_min:abs(theta_max-theta_min)/(L2-1):theta_max;
for j = 1:L2  
    theta(j,:) = ones([1 L2])*angl(j);
end
theta = theta';

% Set up angles phi
angl2 = phi_min:abs(phi_max-phi_min)/(L2-1):phi_max;
for j = 1:L2  
    phi(j,:) = ones([1 L2])*angl2(j);
end


% Set up autoscaling if required.
% In some interpolation methods NaNs are returned; these are tracked and
% replaced by 0's, but may not always be sufficient. Try a different
% interpolation method.
Zscale = str3;
[ind] = find(isnan(T));
T(ind) = 0;
Zavg = mean(mean(T));
MaxZin = max(max(T-Zavg));
MinZin = min(min(T-Zavg));
Rho_max = Rho + Zscale*MaxZin;
Rho_min = Rho + Zscale*MinZin;
if Rho_min < 0
    Zscale = -Rho/MinZin;
    Rho_min = Rho + Zscale*MinZin;
    disp(['SPHERE3D Warning: Data scaling changed to ',num2str(Zscale),...
        ' to avoid negative radial values.']);
end

% Convert to Cartesian coordinates
for j = 1:L2  
    [Xout(j,:) Yout(j,:) Zout(j,:)] = ...
    sph2cart(theta(j,:),phi(j,:),Rho*ones([1 L2])+Zscale*T(j,:));
end

% Set up color mapping for output
nColor = 50;
[Cmap,Rmax,Rmin] = RadialColorMap(Xout,Yout,Zout,nColor); 

% Plot the data
switch str1;
case 'mesh'   
    colormap([0 0 0]);
    mesh(Xout,Yout,Zout);
    axis vis3d
    axis off;
    grid off;
    set(gca,'DataAspectRatio',[1 1 1]);
    set(gca,'XDir','rev','YDir','rev');
    
case 'meshc'
    Zoutc = Zout + 0.3*max(max(Zout));
    colormap([0 0 0]);
    meshc(Xout,Yout,Zoutc);
    axis off;
    grid off;
    set(gca,'DataAspectRatio',[1 1 1])    
    set(gca,'XDir','rev','YDir','rev'); 
    
case 'surf'   
    surf(Xout,Yout,Zout,Cmap);
    set(gca,'DataAspectRatio',[1 1 1]);
    axis vis3d
    axis off;
    grid off;
    set(gca,'XDir','rev','YDir','rev');
    cbar = colorbar;
    numYTicks = length(get(cbar,'YTickLabel'));
    gap = (MaxZin - MinZin)/(numYTicks-1);
    k = 0:numYTicks-1;
    if gap < 5
        minLabel = round(MinZin*100)/100;
        stepLabel = k.*round(gap*100)/100 + minLabel;
    else
        minLabel = round(MinZin);
        stepLabel = k.*round(gap) + minLabel;
    end    
    colorbar('YTickLabel',stepLabel); 
    
case 'contour' 
    C = contourc(T',25);
    [row,col] = size(C);
    mag(1) = C(1,1);    % magnitude at nLevel = 1
    num = C(2,1);       % number of (x,y)contour pairs at nLevel = 1
    finished = 0;       %
    sumPairs = 0;       % total number of (x,y) contour pairs at all levels
    nLevel = 1;         % nth contour level

    % retrieve contour coordinates (x,y) from contourc function output
    while ~finished
        x(1:num,nLevel) = C(1,2:num+1);
        y(1:num,nLevel) = C(2,2:num+1);
        C(1,:) = shift(C(1,:),-(num+1));
        C(2,:) = shift(C(2,:),-(num+1));
        sumPairs = sumPairs + num + 1;
        nLevel = nLevel + 1;
        num = C(2,1);
        mag(nLevel) = C(1,1);
        if sumPairs >= col
            finished = 1;
        end
    end
    % Replace zeros with NaNs in x and y
    [ind] = find(x == 0);
    x(ind) = NaN;
    [ind] = find(y == 0);
    y(ind) = NaN;

    % set up equivalent phi angles from contour x and radius Rho
    alpha = (x/Rho);
    minalpha = min(min(alpha));
    alpha = alpha - minalpha;
    maxalpha = max(max(alpha));
    alpha = alpha*(phi_max - phi_min)/maxalpha + phi_min;
    minalpha = min(min(alpha));
    maxalpha = max(max(alpha));
    
    % set up equivalent theta angles from contour y and radius Rho
    gamma = (y/Rho);
    mingamma = min(min(gamma));
    gamma = gamma - mingamma;
    maxgamma = max(max(gamma));
    gamma = gamma*(theta_max - theta_min)/maxgamma + theta_min;
    mingamma = min(min(gamma));
    maxgamma = max(max(gamma));
    
    % convert to cartesian
    Xsph = Rho*cos(alpha).*cos(gamma); 
    Ysph = Rho*cos(alpha).*sin(gamma);
    Zsph = Rho*sin(alpha);

    % draw contour lines one at a time with preset colour in rgbCol
%  figure
    nCol = (nLevel-2:-1:0)'/nLevel;
    rgbCol = hsv2rgb(0.8*[nCol ones(nLevel-1,2)]);
    maxZ = max(max(Zin));
    minZ = min(min(Zin));
    caxis([minZ, maxZ]);
    caxis manual
    %colorbar
    [r,c] = size(Xsph);
    for i = 1:nLevel-1
        xx(1:r) = Xsph(:,i);
        yy(1:r) = Ysph(:,i);
        zz(1:r) = Zsph(:,i);
        line(xx,yy,zz,'Color',[rgbCol(i,1) rgbCol(i,2) rgbCol(i,3)]);
    end
    xmin = -Rho; xmax = Rho;
    ymin = -Rho; ymax = Rho;
    zmin = -Rho; zmax = Rho;
    axis([xmin xmax ymin ymax zmin zmax])
    axis vis3d
    set(gca,'DataAspectRatio',[1 1 1])
    set(gca,'XDir','rev','YDir','rev')
    axis off;
    grid off;

% set up sphere plot borders
    nPoints = 80;
    j = 1:nPoints;
    theta1 = theta_min + (j-1)*(theta_max - theta_min)/(nPoints - 1);
    phi1 = phi_min + (j-1)*(phi_max - phi_min)/(nPoints - 1);
    XborderRight = Rho*cos(phi1)*cos(theta_max); 
    YborderRight = Rho*cos(phi1)*sin(theta_max); 
    ZborderRight = Rho*sin(phi1); 
    XborderLeft = Rho*cos(phi1)*cos(theta_min); 
    YborderLeft = Rho*cos(phi1)*sin(theta_min); 
    ZborderLeft = Rho*sin(phi1);
    XborderTop = Rho*cos(phi_max)*cos(theta1); 
    YborderTop = Rho*cos(phi_max)*sin(theta1); 
    ZborderTop = Rho*ones(size(phi1))*sin(phi_max);
    XborderBot = Rho*cos(phi_min)*cos(theta1); 
    YborderBot = Rho*cos(phi_min)*sin(theta1); 
    ZborderBot = Rho*ones(size(phi1))*sin(phi_min);

% plot borders on sphere
    BorderLine(XborderRight,YborderRight,ZborderRight,Rho);
    BorderLine(XborderTop,YborderTop,ZborderTop,Rho);
    BorderLine(XborderBot,YborderBot,ZborderBot,Rho); 
    BorderLine(XborderLeft,YborderLeft,ZborderLeft,Rho);
end %switch

%
% Local Functions
%
    function BorderLine(Xborder,Yborder,Zborder,Rho)
        % Draws a border line defined by (Xborder,Yborder,Zborder).
        % Used to plot borders of contour on spherical surface.
        %
        hold on
        line(Xborder,Yborder,Zborder,'Color',[.5 .5 .5]);
        xlo = -Rho; xhi = Rho;
        ylo = -Rho; yhi = Rho;
        zlo = -Rho; zhi = Rho;
        axis([xlo xhi ylo yhi zlo zhi]);
        axis vis3d;
        set(gca,'XDir','rev','YDir','rev');
        axis off;
        grid off;
        hold off;
        return

    function [A] = shift(A,n)
        %
        % SHIFT     moves each element down by n steps along vector A,
%  treating the positions j as though they are on a circle,
%  so that A(j) moves to position(j+n), and A(L-n+1:L)occupy
%  positions(1:n), where L is the number of elements in A.
%  If n is positive the shift is in the forward direction
%  whereas if negative, the shift is backwards.
        %
%% Syntax
%  [A] = shift(A,n)
        %
%% Input
%  A,  array whose elements will be shifted
%  n,  number of shifts to perform
%  n can be negative as well.
        %
%% Output
%  A,  array with shifted elements.
        %
        change = 0;
        [r,c] = size(A);
        if (r > 1)&(c == 1)
            A = A'; change = 1;
        end
        [r,c] = size(A);
        if (r == 1)&(c >= 1)
            [r,c] = size(n);
            if (r == 1)&(c == 1)
                n = round(n);
                L = length(A);
                n = rem(n,L);
                if n < 0 n = L + n; end
                T = A;
                A(n+1:L) = T(1:L-n);
                A(1:n) = T(L-n+1:L);
            else
                disp('Shift warning: number of shifts cannot be a vector or matrix');
            end
        else
            disp('Shift warning: input must be row or column vector');
        end
        if change == 1 A = A'; end;
        return      
        
   function [Cmap,Rmax,Rmin] = RadialColorMap(X,Y,Z,nColor)
       % RadialColorMap     maps a colour scale to the radial information
%  formed from coordinates X, and Y. The number of
%  colors formed is nColor.
       %
%% Syntax
%  [Cmap,Rmax,Rmin] = RadialColorMap(X,Y,nColor)
       %
%% Input
%  X       a square matrix of X-coordinates
%  Y       a square matrix of Y-coordinates
%  Z       a square matrix of Z-coordinates
%  nColor  number of colours to use
       %
%% Output
%  Cmap    the colour map
%  Rmax    maximum radius of input data
%  Rmin    minimum radius of input data
       %
       R = sqrt(X.^2 + Y.^2 + Z.^2);
       [r,c] = size(R);
       Rmax = max(max(R));
       Rmin = min(min(R));
       Col = (Rmax - Rmin)/(nColor-1);
       for i = 1:r
           for j = 1:r
               for k = 1:nColor
                   if (R(i,j)>= Rmin + (k-1)*Col)&(R(i,j) < Rmin + k*Col)
                       Cmap(i,j) = Rmin + (k-1)*Col;
                   end
               end
           end
       end 
       return
            
return

    






