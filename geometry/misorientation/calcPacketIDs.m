function [packetId] = calcPacketIDs(hklParent,hklChild,p2c,variantIDs)
%
% Syntax
%
%  childId = calcPacketIDs(hklParent,hklChild,p2c,variantIDs)
%
% Input
%  hklParent  - Habit planes in the parent phase
%  hklChild   - Habit plane in the child phase
%  p2c        - parent to child mis@orientation
%  variantIDs - List of identified variantIDs 
%
% Output
%  packetId   - child variant Id
%
% Description
%
%
  omega = dot(variants(p2c,hklParent),hklChild);
  [~,packetId] = max(omega,[],2);  
  packetId = packetId(variantIDs);
  