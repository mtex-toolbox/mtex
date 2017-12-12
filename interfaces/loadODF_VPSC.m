function [odf,options] = loadODF_VPSC(fname,varargin)

odf = ODF;
options = {};

% read file header
hl = file2cell(fname,4);

% check that this is a vpsc text file
assert(~isempty(strmatch('TEXTURE AT STRAIN',hl{1})),...
  'Interface VPSC does not fit file format!');
  
if check_option(varargin,'check'), return; end

% import the data
[odf,options] = loadODF_generic(fname,'bunge','degree',...
  'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'weights'},'density',varargin{:});
