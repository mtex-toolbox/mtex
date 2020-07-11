function startup

if ~ isdeployed
    % add root
    addpath(fileparts(mfilename('fullpath')),0);
end

% startup MTEX
startup_mtex;
