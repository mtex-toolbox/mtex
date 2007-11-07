function plotodf(odf,varargin)
% plot odf
%
% Plots the ODF as various sections which can be controled by options. 
%
%% Input
%  odf - @ODF
%
%% Options
%  SECTIONS   - number of plots
%  RESOLUTION - resolution of each plot
%  h          - @Miller / @vector3d reference crystal direction (omega plot)
%  r          - reference specimen direction (omega plot)
%  CENTER     - for radially symmetric plot
%  AXES       - for radially symmetric plot
%
%% Flags
%  SIGMA (default)
%  ALPHA
%  GAMMA      
%  PHI1
%  PHI2
%  OMEGA (buggy)
%  RADIALLY
%
%% See also
% S2Grid/plot savefigure

set(gcf,'Name',['ODF "',inputname(1),'"']);


%% -------- one - dimensional plot ---------------------------------------
if check_option(varargin,'RADIALLY')   

  center = get_option(varargin,'CENTER',quaternion(1,0,0,0),'quaternion');
  axes = get_option(varargin,'AXES',[xvector,yvector,zvector]);
 
  omega = linspace(-pi,pi,200);
  for i=1:length(axes)
    q = axis2quat(axes(i),omega);
    d(:,i) = eval(odf,q*center,varargin{:}); %#ok<AGROW>
  end
  plot(omega,d);
  xlim([-pi pi]); xlabel('omega')
  return
  
%% -------- alpha - sections ----------------------------------------------
elseif check_option(varargin,'ALPHA')   

  % alpha
  if rotangle_max_y(odf(1).CS) == pi && rotangle_max_y(odf(1).SS) == pi
    m = pi/2;
  else
    m = rotangle_max_z(odf(1).SS);
  end
  sec = linspace(0,m,get_option(varargin,'SECTIONS',round(m/degree/5))+1); sec(end) = [];
  sec = get_option(varargin,'ALPHA',sec,'double');
  nplots = length(sec);
  
  % beta / gamma
  S2G = S2Grid('PLOT',varargin{:},...
    'MAXTHETA',min(rotangle_max_y(odf(1).CS),rotangle_max_y(odf(1).SS))/2,...
    'MAXRHO',rotangle_max_z(odf(1).CS));
  
  alpha = repmat(reshape(sec,[1,1,nplots]),[GridSize(S2G),1]);
  [beta,gamma] = polar(S2G);
  beta  = reshape(repmat(beta ,[1,1,nplots]),[GridSize(S2G),nplots]);
  gamma = reshape(repmat(gamma,[1,1,nplots]),[GridSize(S2G),nplots]);
  
  rot = euler2quat(alpha,beta,gamma);
  symbol = '\alpha';

%% --------- gamma - sections ---------------------------------------------  
elseif check_option(varargin,'GAMMA')   

  % gamma

  sec = linspace(0,rotangle_max_z(odf(1).CS),...
    get_option(varargin,'SECTIONS',...
    round(rotangle_max_z(odf(1).CS)/degree/5))+1); 
  sec(end) = [];
  sec = get_option(varargin,'GAMMA',sec,'double');
  nplots = length(sec);
  
  % alpha / beta
  if rotangle_max_y(odf(1).CS) == pi && rotangle_max_y(odf(1).SS) == pi
    m = pi/2;
  else
    m = rotangle_max_z(odf(1).SS);
  end
  S2G = S2Grid('PLOT',varargin{:},...
    'MAXTHETA',min(rotangle_max_y(odf(1).CS),rotangle_max_y(odf(1).SS))/2,...
    'MAXRHO',m);
  
  gamma = repmat(reshape(sec,[1,1,nplots]),[GridSize(S2G),1]);
  [beta,alpha] = polar(S2G);
  beta  = reshape(repmat(beta ,[1,1,nplots]),[GridSize(S2G),nplots]);
  alpha = reshape(repmat(alpha,[1,1,nplots]),[GridSize(S2G),nplots]); 
  
  rot = euler2quat(alpha,beta,gamma);
  symbol = '\gamma';
    
  %% -------- phi1 - sections ----------------------------------------------
elseif check_option(varargin,'phi1')   

  % alpha
  if rotangle_max_y(odf(1).CS) == pi && rotangle_max_y(odf(1).SS) == pi
    m = pi/2;
  else
    m = rotangle_max_z(odf(1).SS);
  end
  sec = linspace(0,m,get_option(varargin,'SECTIONS',round(m/degree/5))+1); sec(end) = [];
  sec = get_option(varargin,'phi1',sec,'double');
  nplots = length(sec);
  
  % beta / gamma
  S2G = S2Grid('PLOT',varargin{:},...
    'MAXTHETA',min(rotangle_max_y(odf(1).CS),rotangle_max_y(odf(1).SS))/2,...
    'MAXRHO',rotangle_max_z(odf(1).CS));
  
  phi1 = repmat(reshape(sec,[1,1,nplots]),[GridSize(S2G),1]);
  [Phi,phi2] = polar(S2G);
  Phi  = reshape(repmat(Phi,[1,1,nplots]),[GridSize(S2G),nplots]);
  phi2 = reshape(repmat(phi2,[1,1,nplots]),[GridSize(S2G),nplots]);
  
  rot = euler2quat(phi1,Phi,phi2,'Bunge');
  symbol = '\varphi_1';

%% --------- gamma - sections ---------------------------------------------  
elseif check_option(varargin,'phi2')   

  % gamma

  sec = linspace(0,rotangle_max_z(odf(1).CS),...
    get_option(varargin,'SECTIONS',...
    round(rotangle_max_z(odf(1).CS)/degree/5))+1); 
  sec(end) = [];
  sec = get_option(varargin,'phi2',sec,'double');
  nplots = length(sec);
  
  % alpha / beta
  if rotangle_max_y(odf(1).CS) == pi && rotangle_max_y(odf(1).SS) == pi
    m = pi/2;
  else
    m = rotangle_max_z(odf(1).SS);
  end
  S2G = S2Grid('PLOT',varargin{:},...
    'MAXTHETA',min(rotangle_max_y(odf(1).CS),rotangle_max_y(odf(1).SS))/2,...
    'MAXRHO',m);
  
  phi2 = repmat(reshape(sec,[1,1,nplots]),[GridSize(S2G),1]);
  [Phi,phi1] = polar(S2G);
  Phi  = reshape(repmat(Phi ,[1,1,nplots]),[GridSize(S2G),nplots]);
  phi1 = reshape(repmat(phi1,[1,1,nplots]),[GridSize(S2G),nplots]); 
  
  rot = euler2quat(phi1,Phi,phi2,'Bunge');
  symbol = '\varphi_2';
    

%% ------------ omega - sections ------------------------------------------  
elseif check_option(varargin,'OMEGA')

  h = get_option(varargin,'h',zvector);
  if isa(h,'Miller'), h = vector3d(h,odf(1).CS); end
  r = get_option(varargin,'r',zvector);
  
  % rotate zvector to reference r
  qr = hr2quat(zvector,r);
  % rotate reference h to S2G
  qh = hr2quat(repmat(h,GridSize(S2G)),vector3d(S2G));
  % calc rotations
  rot = reshape(qr*qh,[],1) * axis2quat(h,sec);
  rot = reshape(rot,[GridSize(S2G),nplots]);
  symbol = '\omega';

%% ------------ sigma - sections (default) --------------------------------
else

  % sigma
  sec = linspace(0,rotangle_max_z(odf(1).CS),...
    get_option(varargin,'SECTIONS',...
    round(rotangle_max_z(odf(1).CS)/degree/5))+1);
  sec(end) = [];
  sec = get_option(varargin,'SIGMA',sec,'double');
  nplots = length(sec);
  
  % alpha / beta
  if rotangle_max_y(odf(1).CS) == pi && rotangle_max_y(odf(1).SS) == pi
    m = pi/2;
  else
    m = rotangle_max_z(odf(1).SS);
  end
  S2G = S2Grid('PLOT',varargin{:},...
    'MAXTHETA',min(rotangle_max_y(odf(1).CS),rotangle_max_y(odf(1).SS))/2,...
    'MAXRHO',m);
  
  [beta,alpha] = polar(S2G);
  alpha = reshape(repmat(alpha,[1,1,nplots]),[GridSize(S2G),nplots]);
  beta  = reshape(repmat(beta ,[1,1,nplots]),[GridSize(S2G),nplots]);
  gamma = repmat(reshape(sec,[1,1,nplots]),[GridSize(S2G),1]);
  
  rot = euler2quat(alpha,beta,gamma-alpha);
  symbol = '\sigma';
  
end

%% ------------------------- plot -----------------------------------------
fprintf(['\nplot ',symbol(2:end),' sections, range: ',...
  xnum2str(min(sec)/degree),mtexdegchar,' - ',xnum2str(max(sec)/degree),mtexdegchar,'\n']);
multiplot(@(i) S2G,...
  @(i) eval(odf,rot(:,:,i),varargin{:}),...
  nplots,...
  'DISP',@(i,Z) [' ',symbol(2:end),' = ',xnum2str(sec(i)/degree),mtexdegchar,' ',...
  ' Max: ',xnum2str(max(Z(:))),...
  ' Min: ',xnum2str(min(Z(:)))],...
	'ANOTATION',@(i) ['$',symbol,'=',int2str(sec(i)*180/pi),'^\circ$'],...
  'MINMAX','SMOOTH','TIGHT',...
  varargin{:},'absolute','FontSize',12);

figure(gcf)
