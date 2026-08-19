function [SRight,SLeft] = extractSym(list,varargin)
% extract crystal (SRight) and specimen (SLeft) symmetry from list of input
% arguments. The first 2 symmetries of the list are returned. If there is
% none or just one symmetry in the list, the remaining outputs are set to
% standard specimen symmetry, or left empty when called with the option
% 'empty' - so that "nothing was given" stays distinguishable from a
% deliberately passed triclinic symmetry (which carries its own frame).
%
% Syntax
%   [SRight,SLeft] = extractSym(list)
%   [SRight,SLeft] = extractSym(list,'empty')

SRight = [];
SLeft = [];

isSym = cellfun(@(x) isa(x,'symmetry'),list,'UniformOutput',true);

if any(isSym)
  pos = find(isSym,1);
  SRight = list{pos};
  isSym(pos) = false;

  if any(isSym), SLeft = list{find(isSym,1)}; end
end

if ~check_option(varargin,'empty')
  % fill only what is genuinely missing - this runs on every SO3Fun
  % constructor. Two separate objects, since a shared handle in both slots
  % would couple them
  if isempty(SRight), SRight = specimenSymmetry; end
  if isempty(SLeft), SLeft = specimenSymmetry; end
end

end
