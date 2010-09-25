function plot(T,varargin)
% plot a tensor
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
  
  case 'vp'
    
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,1);
    
    d = vp;
    
  case 'vs1'
    
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,1);
    
    d = vs1;
    
  case 'vs2'
    
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,1);
    
    d = vs2;
    
  case 'pp'

    S2 = S2Grid('equispaced','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX','antipodal',varargin{:});
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,1);
    
    d = pp;
    
  case 'ps1'
    
    S2 = S2Grid('equispaced','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX','antipodal',varargin{:});
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,1);
    
    d = ps1;
    
  case 'ps2'
    
    S2 = S2Grid('equispaced','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX','antipodal',varargin{:});
    [vp,vs1,vs2,pp,ps1,ps2] = velocity(T,S2,1);
    
    d = ps2;
end
    
multiplot(@(i) S2,@(i) d,1,...
  'MINMAX','dynamicMarkerSize',...
  'antipodal','smooth',...
  varargin{:});

%plot(S2,'data',d,'antipodal','smooth',varargin{:});
