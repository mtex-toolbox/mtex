function [packetIDs] = calcPacketIDs(hklParent,hklChild,p2c,variantIDs)
%
% Syntax
%
%  packetIDs = calcPacketIDs(hklParent,hklChild,p2c,variantIDs)
%
% Input
%  hklParent  - Habit planes in the parent phase
%  hklChild   - Habit plane in the child phase
%  p2c        - parent to child mis@orientation or list of variant mis@orientations
%  variantIDs - List of identified variantIDs 
%
% Output
%  packetId   - child variant Id
%
% Description
%
%

%Determine lowest disorientations of parallel child planes
if length(p2c) == length(p2c.variants) %List of variants
    omega = dot(p2c*hklParent,hklChild);
else %OR misorientation
    omega = dot(variants(p2c,hklParent),hklChild);
end
%Determine packet IDs
[~,packetId] = max(omega,[],2);  
if nargin == 3
   packetIDs = packetId; 
else
   packetIDs = nan(size(variantIDs));
   packetIDs(~isnan(variantIDs))= packetId(variantIDs(~isnan(variantIDs)));
end
  