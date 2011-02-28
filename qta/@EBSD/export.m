function export(ebsd,fname,varargin)
% export EBSD data to a ascii file
%
%% Input
%  ebsd - @EBSD
%  fname - filename
%
%% Options
%  BUNGE   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  DEGREE  - output in degree (default)
%  RADIANS - output in radians

d = get(ebsd,'Euler','Bunge',varargin{:});

if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree; 
end

if ~isempty(ebsd(1).X), d = [d,get(ebsd,'xyz')]; end 
if ~isempty(ebsd(1).phase), d = [d,get(ebsd,'phases')]; end %#ok<NASGU>

save(fname,'d','-ASCII','-single');
