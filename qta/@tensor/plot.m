function plot(T,varargin)
% plot a tensor T
% options - missing density (rho, not to be confused with RHOMAX,RHOMIN) for velocity plot
% plotType = 'quadric','YoungsModulus','linearCompressibility','velocity' 
% 
%%
%
%


% define a plotting grid
[maxtheta,maxrho,minrho] = getFundamentalRegionPF(T.CS,varargin{:});
S2 = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX',varargin{:});
  
% decide what to plot
plotType = get_option(varargin,'PlotType','quadric');

switch plotType
  
  case 'quadric'

    d = quadric(T,S2);
    
  case 'YoungsModulus'
    
    d = YoungsModulus(T,S2);
    
  case 'linearCompressibility'
    
    d = linearCompressibility(T,S2);

  case 'shearModulus'
    
    if check_option(varargin,'h')
      
      label = get_option(varargin,'h');
      d = @(i) shearModulus(T,label(i),S2);
      
    else
      
      label = get_option(varargin,'u',xvector);
      d = @(i) shearModulus(T,S2,label(i));        
            
    end
    
  case 'PoissonRatio'
    
    if check_option(varargin,'x')
      
      label = get_option(varargin,'x');
      d = @(i) PoissonRatio(T,label(i),S2);
      
    else
      
      label = get_option(varargin,'y',xvector);
      d = @(i) PoissonRatio(T,S2,label(i));        
            
    end
    
  case 'velocity'
    
    if check_option(varargin,{'pp','ps1','ps2'})
      S2 = S2Grid('equispaced','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',...
        minrho,'RESTRICT2MINMAX','resolution',10*degree,'no_center',varargin{:});
      varargin = ['color','k','MaxHeadSize',0,varargin];
    end

    rho = get_option(varargin,'density',1);
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,rho); %#ok<NASGU>
    d = eval(get_option(varargin,'velocity','pp','char'));
    
  otherwise
    
    error('Unknown plot type!')
end

if isa(d,'double') && ~isreal(d), d = real(d);end

if isa(d,'function_handle')
  multiplot(@(i) S2,@(i) d(i),length(label),...
    'MINMAX','contourf',...
    'ANOTATION',@(i) label(i),...
    varargin{:});
else
  multiplot(@(i) S2,@(i) d,1,...
    'MINMAX','contourf',...
    varargin{:});
end
set(gcf,'tag','tensor');
%plot(S2,'data',d,'antipodal','smooth',varargin{:});
