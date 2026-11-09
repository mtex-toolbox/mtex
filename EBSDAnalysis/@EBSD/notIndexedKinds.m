function [kinds,parts] = notIndexedKinds(ebsd,varargin)
% the kinds of the notIndexed regions of a map, as calcGrains sees them
%
% The closing with alpha fills every notIndexed region narrower than about
% 2*alpha pixels. What it leaves open are the thick parts, and each of
% them is a pore, a pocket, a crack or a void. calcGrains closes a part
% with the radius of its kind, alphaPore, alphaPocket or alphaCrack.
%
% Syntax
%
%   [kinds,parts] = notIndexedKinds(ebsd,'alpha',3.1)
%
%   % plot the cracks and reconstruct with a kind corrected by hand
%   plot(ebsd(kinds == "crack"))
%   kinds(kinds == "crack" & ebsd.x < 1000) = "pocket";
%   grains = calcGrains(ebsd,'alphaCrack',15,'kinds',kinds)
%
% Input
%  ebsd  - @EBSD
%
% Output
%  kinds - categorical per pixel: pore, pocket, crack, void, noise (a thin
%          region, filled by alpha) or indexed
%  parts - table of the thick parts: kind, area in pixels, Feret diameter,
%          Feret^2 / area, border contact, rim length, rim share of the
%          largest orientation
%
% Options
%  alpha - the closing radius in pixels (default 3.1), with every option
%          calcGrains takes, since the rim test uses its criterion
%
% The kinds are decided in this order: a part with Feret^2 / area >= 5 is
% a crack; one touching the edge of the scan is a void; one whose rim is
% held to 85 percent by pixels the criterion connects is a pore; the rest
% are pockets.
%
% See also
% EBSD/calcGrains GrainReconstructionCracks

% an indexed pixel without rotation is notIndexed, as in calcGrains
ebsd.phaseId(isnan(ebsd.rotations) & ebsd.isIndexed) = 1;

out = spatialDecompositionGrid(ebsd,ebsd.lattice,varargin{:},'kindsOnly');
kinds = out.kinds;
parts = out.parts;
