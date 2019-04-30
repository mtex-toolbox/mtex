function export(ebsd,fname,varargin)
% export EBSD data to an ascii file
%
% Syntax
%
%  export(ebsd,'filename.ctf')
%  export(ebsd,'filename.h5')
%  export(ebsd,'filename.txt')
%  export(ebsd,'filename.txt','radians')
%
% Input
%  ebsd - @EBSD
%
% Options
%  Bunge   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  degree  - output in degree (default)
%  radians - output in radians
%


% select method by extension
[~,~,ext] = fileparts(fname);

switch lower(ext)
  
  case '.h5'
    export_h5(ebsd,fname,varargin{:});
  case '.ctf'
    export_ctf(ebsd,fname,varargin{:});
  otherwise
    export_generic(ebsd,fname,varargin{:});
end

end
