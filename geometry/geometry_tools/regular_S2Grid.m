function S2G = regular_S2Grid(varargin)
% constructs a regular S2Grid 
%
%% Options
%  RESOLUTION - resolution of the grid
%  MAXRHO     - maximum rho angle
%  MAXTHETA   - maximum theta angle

maxtheta = get_option(varargin,'MAXTHETA',pi);
maxrho = get_option(varargin,'MAXRHO',2*pi);

if check_option(varargin,'theta')

  theta = get_option(varargin,'theta',[]);
  rho = get_option(varargin,'rho',[]);
  
else
  
  res = get_option(varargin,'resolution',5*degree,'double');

  if length(res) == 1, res = [res,res];end
  res(2) = 2*pi/round(2*pi / res(2));

  theta = linspace(0,maxtheta,maxtheta/res(1));
  rho = linspace(0,maxrho,maxrho/res(2));   
  
end

S2G.res = min(abs(theta(1)-theta(2)),abs(rho(1)-rho(2)));
S2G.theta = S1Grid(theta,0,maxtheta);
S2G.rho = repmat(...
  S1Grid(rho,0,maxrho,'PERIODIC'),...
  1,length(theta));

S2G.Grid = calcGrid(S2G.theta,S2G.rho);
S2G.options = {'INDEXED'};

S2G = class(S2G,'S2Grid');
