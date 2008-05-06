function [pf,options] = loadPoleFigure_generic(fname,varargin)
% load pole figure data from (theta,rho,intensity) files
%
%% Description 
%
% *loadPoleFigure_generic* is a generic function that reads any txt files of
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
% header lines to be ignored using the option |HEADER|. 
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
%  LAYOUT            - [theta rho intensity] - (default [1 2 3])
% 
%% Example
%
%  pf = loadPoleFigure_generic('pf001.txt','HEADER',5,'Layout',[2 3 4],'degree')
%
%% See also
% interfaces_index munich_interface loadPoleFigure


% load data
[d,varargin] = load_generic(fname,varargin{:});

% no data found
if size(d,1) < 10 || size(d,2) < 3
  error('Generic interface could not detect any numeric data in %s',fname);
end

% no options given -> ask
if ~check_option(varargin,'layout')
  
  options = generic_wizard('data',d,'type','PoleFigure');
  if isempty(options), pf = []; return; end 
  varargin = {varargin{:},options{:}};

end

%extract options
dg = degree + (1-degree)*check_option(varargin,'RADIAND');
layout = get_option(varargin,'LAYOUT',[1 2 3]);

try
  
  % eliminate nans
  d(any(isnan(d(:,layout)),2),:) = [];
  
  % extract data
  if length(layout) == 4 && ~isnan(layout(4))
    bg = {'background',d(:,layout(4))};
  else
    bg = {};
  end
  
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
  
  pf = PoleFigure(h,r,d,symmetry('cubic'),symmetry,bg{:},varargin{:});
  options = varargin;
  
catch
  error('Generic interface could not extract data of file %s',fname);
end
