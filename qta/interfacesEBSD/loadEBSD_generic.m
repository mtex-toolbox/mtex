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
%  RADIAND           - treat input in radiand
%  DELIMITER         - delimiter between numbers
%  HEADER            - number of header lines
%  HEADERC           - number of header colums
%  BUNGE             - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  ABG               - [alpha beta gamma] Euler angle in Mathies convention 
%  LAYOUT            - colums of the Euler angle (default [1 2 3])
%
% 
%% Example
%
% ebsd = loadEBSD('ebsd.txt',symmetry('cubic'),symmetry,'header',1,'layout',[5,6,7]) 
%
%% See also
% interfacesEBSD_index loadEBSD ebsd_demo

% load data
[d,varargin] = load_generic(fname,varargin{:});

% no data found
if size(d,1) < 10 || size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% no options given -> ask
if ~check_option(varargin,'layout')
  
  options = generic_wizard('data',d,'type','EBSD');
  if isempty(options), ebsd = []; return; end
  varargin = {varargin{:},options{:}};

end

%extract options
dg = degree + (1-degree)*check_option(varargin,'RADIAND');
layout = get_option(varargin,'LAYOUT',[1 2 3]);
phase = get_option(varargin,'phase',[],'double');
    
try
    
  % eliminate nans
  d(any(isnan(d(:,layout)),2),:) = [];
  
  % extract right phase
  if length(layout) == 4 && ~isempty(phase)    
    d = d(any(d(:,layout(4))==repmat(reshape(phase,1,[]),size(d,1),1),2),:);
  end
 
  % extract data
  alpha = d(:,layout(1))*dg; 
  beta  = d(:,layout(2))*dg;
  gamma = d(:,layout(3))*dg;
  
  mtex_assert(all(beta >=0 & beta <= pi & alpha >= -2*pi & alpha <= 4*pi & gamma > -2*pi & gamma<4*pi));
  
  % get Euler angles option 
  bunge = set_default_option(...
    extract_option(varargin,{'bunge','ABG'}),{'bunge','ABG'},...
    'bunge');
  
  % store data as quaternions
  q = euler2quat(alpha,beta,gamma,bunge{:});  
  
  if check_option(varargin,'inverse'), q = inverse(q); end
  
  SO3G = SO3Grid(q,symmetry('cubic'),symmetry());
  ebsd = EBSD(SO3G,symmetry('cubic'),symmetry(),varargin{:});
  options = varargin;

catch
  error('Generic interface could not extract data of file %s',fname);
  %rethrow(lasterror);
end
