function [ebsd,options] = loadEBSD_generic(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
%% Description 
%
% *loadEBSD_txt* is a generic function that reads any txt files of
% diffraction intensities that are of the following format
%
%  alpha_1 beta_1 gamma_1 phase_1
%  alpha_2 beta_2 gamma_2 phase_2
%  alpha_3 beta_3 gamma_3 phase_3
%  .      .       .       .
%  .      .       .       .
%  .      .       .       .
%  alpha_M beta_M gamma_M phase_m
%
% The actual position and order of the columns in the file can be specified
% by the option |LAYOUT|. Furthermore, the files can be contain any number
% of header lines and columns to be ignored using the options |HEADER| and
% |HEADERC|.
%
%% Syntax
%  pf   = loadEBSD_txt(fname,<options>)
%  pf   = loadEBSD_txt(fname,'layout',[col_phi1,col_Phi,col_phi2]
%
%% Input
%  fname - file name (text files only)
%
%% Options
%  RADIANS           - treat input in radiand
%  DELIMITER         - delimiter between numbers
%  HEADER            - number of header lines
%  HEADERC           - number of header colums
%  BUNGE             - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  ABG               - [alpha beta gamma] Euler angle in Mathies convention 
%  LAYOUT            - colums of the Euler angle (default [1 2 3])
%  XY                - colums of the xy data
%
% 
%% Example
%
% ebsd = loadEBSD('ebsd.txt',symmetry('cubic'),symmetry,'header',1,'layout',[5,6,7]) 
%
%% See also
% interfacesEBSD_index loadEBSD ebsd_demo

% load data
[d,varargin,header,c] = load_generic(fname,varargin{:});

% no data found
if size(d,1) < 10 || size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% no options given -> ask
if ~check_option(varargin,'ColumnNames') || ~check_option(varargin,'Columns')
  
  options = generic_wizard('data',d(1:end<101,:),'type','EBSD','header',header,'colums',c);
  if isempty(options), ebsd = []; return; end
  varargin = {options{:},varargin{:}};

end

cols = get_option(varargin,'Columns');
names = lower(get_option(varargin,'ColumnNames'));

mtex_assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

[names m] = unique(names);
cols = cols(m);

istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(in,x))),a));
layoutcol = @(in, a) cols(cellfun(@(x) find(strcmpi(in,x)),a));
   
euler = lower({'Euler 1' 'Euler 2' 'Euler 3'});
quat = lower({'Quat real' 'Quat i' 'Quat j' 'Quat k'});
      
if istype(names,euler) % Euler angles specified
    
  layout = layoutcol(names,euler);
    
  %extract options
  dg = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});
    
  % eliminate nans
  d(any(isnan(d(:,layout)),2),:) = [];
  
  % eliminate rows where angle is 4*pi
  ind = abs(d(:,layout(1))*dg-4*pi)<1e-3;
  d(ind,:) = [];
    
  % extract data
  alpha = d(:,layout(1))*dg;
  beta  = d(:,layout(2))*dg;
  gamma = d(:,layout(3))*dg;

  mtex_assert(all(beta >=0 & beta <= pi & alpha >= -2*pi & alpha <= 4*pi & gamma > -2*pi & gamma<4*pi));
  
  % check for choosing
  if max(alpha) < 10*degree
    warndlg('The imported Euler angles appears to be quit small, maybe your data are in radians and not in degree as you specified?');
  end
    
  % transform to quaternions
  q = euler2quat(alpha,beta,gamma,varargin{:});
  
elseif istype(names,quat) % import quaternion
    
  layout = layoutcol(names,quat);
  d(any(isnan(d(:,layout)),2),:) = [];
  q = quaternion(d(:,layout(1)),d(:,layout(2)),d(:,layout(3)),d(:,layout(4)));
  
else
  error('You should at least specify three Euler angles or four quaternion components!');
end
   
if check_option(varargin,'passive rotation'), q = inverse(q); end
 
SO3G = SO3Grid(q,symmetry('cubic'),symmetry());
  
%treat other options
xy = [];
if istype(names,{'x' 'y'}),
  xy = d(:,layoutcol(names,{'x' 'y'}));
end
  
phase = [];
if istype(names,{'Phase'}),
  phase = d(:,layoutcol(names,{'Phase'}));
end
  
%all other as options
opt = struct;
opts = delete_option(names,  {euler{:} quat{:} 'Phase' 'x' 'y'});
if ~isempty(opts)
  for i=1:length(opts),
    opts_struct{i} = [opts{i} {d(:,layoutcol(names,opts(i)))}]; %#ok<AGROW>
  end
  opts_struct = [opts_struct{:}];
  opt = struct(opts_struct{:});
end

ebsd = EBSD(SO3G,symmetry('cubic'),symmetry(),varargin{:},'xy',xy,'phase',phase,'options',opt);


options = varargin;
