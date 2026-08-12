classdef EBSDgrid < EBSD
% EBSD data stored as a matrix rather than as a list
%
% The shared base of @EBSDsquare and @EBSDhex. It carries the matrix layout
% and nothing else: id, rotations, pos and every prop are (r x c) instead of
% (n x 1), so the data can be handed to image processing and registration
% tools directly, and ebsd(i,j) addresses a scan position.
%
% It is deliberately NOT a capability tier. Everything an EBSD can be asked
% to compute lives on @EBSD and works on a plain list, via ebsd.lattice - a
% grid class only changes how the same data is stored. Anything added here
% must be a statement about the matrix layout; if it is a statement about
% the measurements, it belongs on @EBSD.
%
% Note that a grid may be rotated relative to the x/y axes and smoothly
% distorted - pos is stored per pixel, not derived from an origin and a
% spacing - so no method here may assume pos(i,j) is an axis aligned affine
% function of (i,j).
%
% Derived classes
%
%  @EBSDsquare - pos(i,j) is affine in (i,j)
%  @EBSDhex    - rows (or columns) are staggered by half a step, so it is
%                not; the (row,col) <-> lattice conversion needs the parity
%
% See also
% EBSD EBSDsquare EBSDhex EBSD/gridify EBSD/lattice

% Still on @EBSDsquare rather than here, deliberately - each needs a decision
% about hex before it can be shared, and none of them is the mechanical move
% it looks like:
%
%  end      - returns size(id,1) for linear indexing, so ebsd(end) is the last
%             element of the FIRST COLUMN, not the last element. Long standing;
%             moving it would propagate that to hex rather than fix it.
%  subGrid  - crops a rectangle in matrix space; on a staggered grid the
%             cropped block's offset parity has to be carried with it.
%  gridify  - the square override is a no-op for an already gridded map. Hex
%             has none, so it re-runs hexify, which rebuilds pos from
%             theoretical coordinates instead of keeping the measured ones.
%             Making it a no-op is right, but it is a behaviour change.
%  d1, d2   - well defined for both as the step between adjacent matrix
%             entries, but for hex that is not a lattice translation.

  methods
  end

end
