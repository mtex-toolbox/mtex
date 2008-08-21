function pf = loadPoleFigure_juelich(fname,varargin)
% load juelich data format
%
%% Input
%  fname - file name
%
%% Output
%  pf    - vector of @PoleFigure
%
%% See also
% interfaces_index juelich_interface loadPoleFigure

% check second commentar line
% alpha      beta intensity
fid = efopen(fname);
fgetl(fid); 
l = fgetl(fid);
mtex_assert(strcmp(l,'     alpha      beta intensity'));
fclose(fid);

% call txt interface with the right parameters
pf = loadPoleFigure_txt(fname,'HEADER',2,varargin{:});
