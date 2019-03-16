function [t,options] = loadTensor_json(fname,varargin)

[~,~,ext] = fileparts(fname);
if ~strcmpi(ext,'.json'), interfaceError(fname), end

s = loadjson(fname);

type = char(fieldnames(s));

s = s.(type);

cs = crystalSymmetry(s.CS.pointGroup,s.CS.abc,s.CS.abg,s.CS.alignment{:},'mineral',s.CS.mineral);

t = feval(type,s.M,cs,'rank',s.rank);
try t.opt = s.opt; end

options = {};