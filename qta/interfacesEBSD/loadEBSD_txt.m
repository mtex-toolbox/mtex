function ebsd = loadEBSD_txt(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
%% Description 
%
% *loadEBSD_txt* is a generic function that reads any txt files of
% diffraction intensities that are of the following format
%
%  alpha_1 beta_1 gamma_1
%  alpha_2 beta_2 gamma_2
%  alpha_3 beta_3 gamma_3
%  .      .       .
%  .      .       .
%  .      .       .
%  alpha_M beta_M gamma_M
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
% interfaces_index munich_interface loadPoleFigure

dg = degree + (1-degree)*check_option(varargin,'RADIAND');
dl = get_option(varargin,'DELIMITER','');
hl = get_option(varargin,'HEADER',0);
hr = get_option(varargin,'HEADERC',0);
layout = get_option(varargin,'LAYOUT',[1 2 3]);

try
  % read data
	d = dlmread(fname,dl,hl,hr);
	alpha = d(:,layout(1))*dg; 
  beta  = d(:,layout(2))*dg;
	gamma = d(:,layout(3))*dg;
  
  
  bunge = set_default_option(...
    extract_option(varargin,{'bunge','ABG'}),{'bunge','ABG'},...
    'bunge');
  q = euler2quat(alpha,beta,gamma,bunge{:});  
  
  if check_option(varargin,'inverse'), q = inverse(q); end
  
  %disp(set_default_option(...
  %  extract_option(varargin,{'bunge','ABG'}),...
  %  'bunge'));
  
  SO3G = SO3Grid(q,symmetry('cubic'),symmetry());
  ebsd = EBSD(SO3G,symmetry('cubic'),symmetry(),varargin{:});
catch
  error('format txt does not match file %s',fname);
end
