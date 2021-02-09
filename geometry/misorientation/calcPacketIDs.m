function [packetIDs] = calcPacketIDs(hklParent,hklChild,p2c,variantIDs)
%
% Syntax
%
%   packetIDs = calcPacketIDs(hklParent,hklChild,p2c,variantIDs)
%
% Input
%  hklParent  - habit planes in the parent phase
%  hklChild   - habit plane in the child phase
%  p2c        - parent to child mis@orientation or list of variant mis@orientations
%  variantIDs - list of identified variantIDs 
%
% Output
%  packetId   - child variant Id
%
% Description
%
%

% determine lowest disorientations of parallel child planes
if length(p2c) == length(p2c(1).variants) %List of variants
  omega = dot(p2c*hklParent,hklChild);
else % OR misorientation
  omega = dot(variants(p2c,hklParent),hklChild);
end

% determine packet IDs
[~,packetId] = max(omega,[],2);  
if nargin == 3
   packetIDs = packetId; 
else
   packetIDs = nan(size(variantIDs));
   packetIDs(~isnan(variantIDs))= packetId(variantIDs(~isnan(variantIDs)));
end
  