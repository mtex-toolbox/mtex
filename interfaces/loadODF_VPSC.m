function [odf,options] = loadODF_VPSC(fname,varargin)

odf = ODF;
options = {};

% read file header
hl = file2cell(fname,4);

% check that this is a vpsc text file
if isempty(strmatch('TEXTURE AT STRAIN',hl{1})); 
  error('MTEX:wrongInterface','Interface ctf does not fit file format!');
elseif check_option(varargin,'check')
  return
end

% set default values for the crystal and specimen symmetry
cs = crystalSymmetry('cubic');

% import the data
[odf,options] = loadODF_generic(fname,'cs',cs,'bunge','degree',...
  'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'weights'},'density',varargin{:});
