function S2G = plot_S2Grid(varargin)
% constructs a regular S2Grid used for density and surface plots on the sphere
%
%% Options
%  RESOLUTION - resolution of the grid
%  MAXRHO     - maximum rho angle
%  MAXTHETA   - maximum theta angle

     
maxtheta = get_option(varargin,'MAXTHETA',pi/2);
maxrho = get_option(varargin,'MAXRHO',2*pi);

res = pi/2/round(pi/2/get_option(varargin,'RESOLUTION',2.5*degree));
ntheta = ceil(maxtheta/res);
nrho = ceil(maxrho/res);

S2G.res = res;
S2G.theta = S1Grid(res*(0:ntheta),0,maxtheta);
S2G.rho = repmat(...
  S1Grid(res*(0:nrho),0,maxrho,'PERIODIC'),...
  1,ntheta+1);
    
 
S2G.Grid = calcGrid(G.theta,G.rho);
S2G.options = {'INDEXED,PLOT'};

S2G = class(S2G,'S2Grid');
    