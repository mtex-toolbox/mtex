function plot(T,varargin)
% plot a tensor T
%
% Input
%  T - @tensor
%
% Options
%  plotType - directionalMagnitude
%             YoungsModulus
%             linearCompressibility
%             velocity'
%  3d - plot surface of plotType instead of spherical projection
%  section - plot a section 
%            -- @vector3d - of given plane normal
%
%

[mtexFig,isNew] = newMtexFigure(varargin{:});

if check_option(varargin,'section')
  omega = linspace(-pi,pi,361);
  
  n = get_option(varargin,'section',zvector,{'cell','vector3d'});
  
  if iscell(n)
    if numel(n)>1
      eta = n{2};
    else
      eta = pi/2;
    end
    n = n{1};
  elseif isa(n,'vector3d')
    eta = pi/2;
  end
  
  S2 = axis2quat(n,omega)*axis2quat(orth(n),eta)*n;
elseif check_option(varargin,'3d')
  
  [x,y,z] = sphere(90);
  S2 = vector3d(x,y,z);
%   S2 = S2Grid('regular','resolution',120varargin{:});
  
else
  % define a plotting grid
  
  if iseven(T.rank)
    varargin = [varargin,'antipodal'];
  end 
  
  sR = fundamentalSector(T.CS,varargin{:});
  S2 = plotS2Grid(sR,varargin{:});
  
end
% decide what to plot
plotType = get_option(varargin,'PlotType','directionalMagnitude');

switch lower(plotType)
  
  case 'directionalmagnitude'
    
    d = directionalMagnitude(T,S2);
    
  case 'youngsmodulus'
    
    d = YoungsModulus(T,S2);
    
  case 'linearcompressibility'
    
    d = linearCompressibility(T,S2);
    
  case 'shearmodulus'
    
    if check_option(varargin,'h')
      
      label = get_option(varargin,'h');
      d = @(i) shearModulus(T,label(i),S2);
      
    else
      
      label = get_option(varargin,'u',xvector);
      d = @(i) shearModulus(T,S2,label(i));
      
    end
    
  case 'poissonratio'
    
    if check_option(varargin,'x')
      
      label = get_option(varargin,'x');
      d = @(i) PoissonRatio(T,label(i),S2);
      
    else
      
      label = get_option(varargin,'y',xvector);
      d = @(i) PoissonRatio(T,S2,label(i));
      
    end
    
  case 'velocity'
    
    if check_option(varargin,{'pp','ps1','ps2'})
      S2 = equispacedS2Grid('resolution',10*degree,'no_center','antipodal',varargin{:});
      S2 = S2(sR.checkInside(S2));
      
      varargin = ['color','k','MaxHeadSize',0,varargin];
      if check_option(varargin,'complete')
        varargin = [varargin,{'removeAntipodal'}];
      end
    end
        
    if isfield(T.opt,'density')
      rho = T.opt.density;
    elseif check_option(varargin,'density')
      rho = get_option(varargin,'density',1);
    else
      error(['No density given! For computing wave velocities '...
        'the material density has to be specified. ' ...
        'Please use the option ..''density'',value.. to do this.']);
    end
        
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,rho); %#ok<ASGLU>
    d = eval(get_option(varargin,'velocity','pp','char'));
    
  otherwise
    
    error('Unknown plot type!')
end

if isa(d,'double') && ~isreal(d), d = real(d);end


if check_option(varargin,'section')
  
  xx = d(:).*cos(omega(:));
  yy = d(:).*sin(omega(:));
  
  h = plot(xx,yy);
  axis equal
  optiondraw(h,varargin{:});

elseif check_option(varargin,'3d')
  
  [x,y,z] = double(abs(d).*S2);
  
  h = surf(x,y,z);
  set(h,'CData',d)
  axis equal
  optiondraw(h,varargin{:});

else
  
  if isa(d,'vector3d')
    d.antipodal = true;
    quiver(S2,d,varargin{:});
  else
    plot(S2,d,'contourf',varargin{:});
  end
  
end

set(gcf,'tag','tensor');

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end

%plot(S2,'data',d,'antipodal','smooth',varargin{:});
