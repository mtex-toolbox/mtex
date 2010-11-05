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
S2 = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX','antipodal',varargin{:});
  
% decide what to plot
plotType = get_option(varargin,'PlotType','quadric');

switch plotType
  
  case 'quadric'

    d = quadric(T,S2);
    
  case 'YoungsModulus'
    
    d = YoungsModulus(T,S2);
    
  case 'linearCompressibility'
    
    d = linearCompressibility(T,S2);
  
  case 'velocity'
    
    if check_option(varargin,{'pp','ps1','ps2'})
      S2 = S2Grid('equispaced','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',...
        minrho,'RESTRICT2MINMAX','antipodal','resolution',10*degree,varargin{:});
      varargin = ['color','k','MaxHeadSize',0,varargin];
    end
% *** need density rho here not one ! ****
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,1); %#ok<NASGU>
    d = eval(get_option(varargin,'velocity','pp','char'));
    
end
    
multiplot(@(i) S2,@(i) d,1,...
  'MINMAX','dynamicMarkerSize',...
  'antipodal','smooth',...
  varargin{:});

%plot(S2,'data',d,'antipodal','smooth',varargin{:});
