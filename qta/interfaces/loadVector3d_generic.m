function [v,options] = loadVector3d_generic(fname,varargin)
% load pole figure data from (alpha,beta,gamma) files
%
%% Description
%
% *loadVector3d_generic* is a  function that reads any txt or exel files 
% The assoziation of the columns as cartesian coordinates or polar angles 
% is specified by the options |ColumnNames| and |Columns|. The files can be
% contain any number of header lines.
%
%% Syntax
%  v   = loadVector3d_generic(fname,'ColumnNames',{'x','y','z'})
%  v   = loadVector3d_generic(fname,'ColumnNames',{'latitude','longitude'})
%  v   = loadVector3d_generic(fname,'ColumnNames',{'polar angle','azimuth'})
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


loader = loadHelper(d,varargin{:});

v      = loader.getVector3d();
  


function str = stripws(str)

str = strrep(str,' ','');
