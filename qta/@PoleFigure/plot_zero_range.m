function NS3G = plot_zero_range(pf,varargin)
% implements the zero range method
%
%% Input
%  pf  - @PoleFigure
%  S3G - initial @SO3Grid
%
%% Output
%  NS3G - reduced @SO3Grid
%
%% Options
% 
%
%% See also
% PoleFigure/calcODF


global mtex_path;

% plotting grid
S2G = S2Grid('PLOT','hemisphere',varargin{:});
% transform in polar coordinates -> output nodes
[out_theta,out_rho] = polar(S2G);
out_theta= fft_theta(out_theta);
out_rho  = fft_rho(out_rho);
S2Gr  = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];

% kernel used for calculation
k = kernel('de la Vallee Poussin','halfwidth',...
  get_option(varargin,'zr_halfwidth',2.5*degree),varargin{:});

% legendre coefficents
Al = getA(k); Al(2:2:end) = 0;


% loop over pole figures
for ip = 1:length(pf)

  fprintf('applying zero range method to %s \n',char(getMiller(pf(ip))));
  
  % in - nodes to become r
  [in_theta,in_rho] = polar(pf(ip).r);
  in_theta = fft_theta(in_theta);
  in_rho   = fft_rho(in_rho);
  gh = [reshape(in_rho,1,[]);reshape(in_theta,1,[])];
  
  % normalization
  r = gh;
  c = ones(size(pf(ip).data));
  c = reshape(run_linux([mtex_path,'/c/bin/odf2pf'],'EXTERN',gh,r,c,Al),...
    size(c));
  
  % c - coefficients
  delta = get_option(varargin,'zr_delta',0.01,'double');
  bg = get_option(varargin,'zr_bg',delta * max(pf(ip).data(:)));
  if length(bg)>1, bg = bg(ip);end
  c = (get_option(varargin,'zr_factor',10)*(pf(ip).data > bg)-1)./c;
  
  
  r = S2Gr;
  f{ip} = run_linux([mtex_path,'/c/bin/odf2pf'],'EXTERN',gh,r,c,Al);
  f{ip} = reshape(f{ip},GridSize(S2G));
  f{ip}(f{ip}>=-0.1) = 1;
  f{ip}(f{ip}<-0.1) = 0;
  
end

multiplot(@(i) S2G,@(i) f{i},length(f),...
  'DISP',@(i,Z) [' PDF h=',char(getMiller(pf(i))),...
  ' Max: ',num2str(max(Z(:))),...
  ' Min: ',num2str(min(Z(:)))],...
  'ANOTATION',@(i) char(getMiller(pf(i)),'LATEX'),...
  'MINMAX',...
  varargin{:},'smooth','interp');

