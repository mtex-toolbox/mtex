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

d = get([ebsd.orientations],'Euler','Bunge',varargin{:});

if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree; 
end

if ~isempty(ebsd.xy), d = [d,ebsd.xy(:)]; end 
if ~isempty(ebsd.phase), d = [d,ebsd.phase(:)]; end %#ok<NASGU>

save(fname,'d','-ASCII','-single');
