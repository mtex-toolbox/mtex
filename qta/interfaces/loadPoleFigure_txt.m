function pf = loadPoleFigure_txt(fname,varargin)
% load pole figure data from (theta,rho,intensity) files
%
%% Description 
%
% *loadPoleFigure_txt* is a generic function that reads any txt files of
% diffraction intensities that are of the following format
%
%  theta_1 rho_1 intensity_1
%  theta_2 rho_2 intensity_2
%  theta_3 rho_3 intensity_3
%  .      .       .
%  .      .       .
%  .      .       .
%  theta_M rho_M intensity_M
%
% The actual order of the columns in the file can be specified by the
% option |LAYOUT|. Furthermore, the files can be contain any number of
% header lines and columns to be ignored using the options |HEADER| and
% |HEADERC|. 
%
%% Syntax
%  pf   = loadPoleFiguretxt(fname,<options>)
%
%% Input
%  fname - file name (text files only)
%
%% Options
%  RADIAND           - treat input in radiand
%  DELIMITER         - delimiter between numbers
%  HEADER            - number of header lines
%  HEADERC           - number of header colums
%  LAYOUT            - [theta rho intensity] - (default [1 2 3])
% 
%% Example
%
%  pf = loadPoleFigure_txt('pf001.txt','HEADER',5,'Layout',[2 3 4],'degree')
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
	th = d(:,layout(1))*dg; 
  rh = d(:,layout(2))*dg;
	d  = d(:,layout(3));

  if all(th<=0), th = -th;end
  assert(length(d)>10 && all(th>=0 & th <= pi) && ...
    all(rh>=-360) && all(rh<=720));

  % specimen directions
	r = S2Grid(sph2vec(th,rh),'reduced');
  
  % crystal direction
  h = string2Miller(fname);
  
  pf = PoleFigure(h,r,d,symmetry('cubic'),symmetry,varargin{:});
catch
  error('format txt does not match file %s',fname);
end
