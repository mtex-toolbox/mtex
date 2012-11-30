function [v,options] = loadvector3d_generic(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
%% Description
%
% *loadvector3d_generic* is a  function that reads any txt or exel files 
% The assoziation of the columns as cartesian coordinates or polar angles 
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
%% Syntax
%  v   = loadvector3d_generic(fname,'ColumnNames',{'x','y','z'})
%  v   = loadvector3d_generic(fname,'ColumnNames',{'latitude','longitude'})
%  v   = loadvector3d_generic(fname,'ColumnNames',{'polar angle','azimuth'})
%
%% Input
%  fname - file name (text files only)
%
%% Options
%  ColumnNames       - names of the colums to be imported
%  Columns           - postions of the columns to be imported
%  RADIANS           - treat input in radiand
%  DELIMITER         - delimiter between numbers
%
%% See also
% 
% azimuth, longitude - angle in the xy plane
% polar angle, colatitude
% latitude
% 

% load data
[d,options,header,c] = load_generic(char(fname),varargin{:});

varargin = options;

% no data found
if size(d,1) < 1 || size(d,2) < 2
  error('Generic interface could not detect any numeric data in %s',fname);
end

% no options given -> ask
if ~check_option(varargin,'ColumnNames')
  
  options = generic_wizard('data',d(1:end<101,:),'type','vector3d','header',header,'columns',c);
  if isempty(options), v = []; return; end
  varargin = [options,varargin];
  
end

names = lower(get_option(varargin,'ColumnNames'));
cols = get_option(varargin,'Columns',1:length(names));


assert(length(cols) == length(names), 'Length of ColumnNames and Columns differ');

[names m] = unique(names);
cols = cols(m);

istype = @(in, a) all(cellfun(@(x) any(find(strcmpi(stripws(in),stripws(x)))),a));
layoutcol = @(in, a) cols(cell2mat(cellfun(@(x) find(strcmpi(stripws(in(:)),stripws(x))),a(:),'uniformoutput',false)));

cart = lower({'x' 'y' 'z'});
polarAngle = {'polar angle','lattitude','collatitude'};
azimuth = lower({'longitude','azimuth'});
  
% polar coordinates
if check_option(names,polarAngle) && check_option(names,azimuth)
  
  %extract options
  dg = degree + (1-degree)*check_option(varargin,{'radians','radiant','radiand'});
    
  % polar angle
  pos = cols(cellfun(@(x) any(strcmpi(x,polarAngle)),names));
    
  theta = d(:,pos)*dg;
  
  if check_option(names,'lattitude')
    theta = pi/2 - theta;
  end
  
  % azimuth
  pos = cols(cellfun(@(x) any(strcmpi(x,azimuth)),names));
  rho  = d(:,pos)*dg;
  
  % check for correctness
  assert(all(theta >=0 & theta <= pi & rho >= -2*pi & rho <= 4*pi));
  
  % check for choosing
  if max(abs([theta(:);rho(:)])) < 10*degree
    warndlg('The imported Euler angles appears to be quit small, maybe your data are in radians and not in degree as you specified?');
  end
  
  v = vector3d('polar',theta,rho);
  
  % cartesian coordinates specified
elseif istype(names,cart)
  
  layout = layoutcol(names,cart);
  d(any(isnan(d(:,layout)),2),:) = [];
  
  v = vector3d(d(:,layout(1)),d(:,layout(2)),d(:,layout(3)));
  
else
  
  error('You should at least specify thwo polar angles or three coordinates!');
  
end
  


function str = stripws(str)

str = strrep(str,' ','');
