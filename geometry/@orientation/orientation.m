classdef (InferiorClasses = {?rotation,?quaternion}) orientation < rotation
% orientation - class representing orientations
%
% This MTEX class represents orientations and misorientations. 
%
% orientation('Euler',phi1,Phi,phi2,cs)  defines an orientation in Euler angles
%

properties
  
  CS = crystalSymmetry('1');
  SS = specimenSymmetry('1');
  
end

methods

  function o = orientation(varargin)
    % defines an orientation
    %
    % Syntax
    %   ori = orientation(rot,cs,ss)
    %   ori = orientation('Euler',phi1,Phi,phi2,cs,ss)
    %   ori = orientation('Euler',alpha,beta,gamma,'ZYZ',cs,ss)
    %   ori = orientation('Miller',[h k l],[u v w],cs,ss)
    %   ori = orientation(name,cs,ss)
    %   ori = orientation('axis,v,'angle',omega,cs,ss)
    %   ori = orientation('matrix',A,cs)
    %   ori = orientation('map',u1,v1,u2,v2,cs)
    %   ori = orientation('quaternion',a,b,c,d,cs)
    %
    % Input
    %  rot       - @rotation
    %  cs, ss    - @symmetry
    %  u1,u2     - @Miller
    %  v, v1, v2 - @vector3d
    %  name      - named orientation
    %    currently available:
    %
    %    * 'Cube', 'CubeND22', 'CubeND45', 'CubeRD'
    %    * 'Goss', 'invGoss'
    %    * 'Copper', 'Copper2'
    %    * 'SR', 'SR2', 'SR3', 'SR4'
    %    * 'Brass', 'Brass2'
    %    * 'PLage', 'PLage2', 'QLage', 'QLage2', 'QLage3', 'QLage4'
    %
    % Ouptut
    %  ori - @orientation
    %
    % See also
    % quaternion_index orientation_index
    
    % find and remove symmetries
    args  = cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true);
    sym = varargin(args);
    varargin(args) = [];
    
    % call rotation constructor
    o = o@rotation(varargin{:});

    if nargin == 0, return;end
    
    % set symmetry
    if ~isempty(varargin) && isa(varargin{1},'orientation')
      o.CS = varargin{1}.CS;
      o.SS = varargin{1}.SS;
    elseif ~isempty(varargin) && ischar(varargin{1}) && strcmpi(varargin{1},'map')
      if isa(varargin{2},'Miller'), o.CS = varargin{2}.CS; end
      if isa(varargin{3},'Miller'), o.SS = varargin{3}.CS; end
    end
    if ~isempty(sym), o.CS = sym{1};end
    if length(sym) > 1, o.SS = sym{2};end
    
    % empty constructor -> done
    if isempty(varargin), return; end
    
    % some predefined orientations
    [names,phi1,Phi,phi2] = oriList;
        
    % copy constructor
    switch class(varargin{1})
       
      case 'char'
  
        switch lower(varargin{1})
          
          case 'miller'
            
            if ~isa(o.CS,'crystalSymmetry')
              o.CS = varargin{2}.CS;
            end
            o = orientation(Miller2quat(varargin{2:3},o.CS),o.CS,o.SS);       
  
          case lower(names)
      
            found = strcmpi(varargin{1},names);
            o = orientation('Euler',phi1(found),Phi(found),phi2(found),...
              'Bunge',o.CS,o.SS);
            
          otherwise
        
            if exist([varargin{1},'Orientation'],'file') 

              % there is a file defining this specific orientation
              o = eval([varargin{1},'Orientation(o.CS,o.SS)']);
            
            end
        end
    end
  end
end

end

% --------------- some predefined orientations ----------------------

function [names,phi1,Phi,phi2] = oriList
  
   orientationList = {
    {'Cube',0,0,0},...
    {'CubeND22',22,0,0},...
    {'CubeND45',45,0,0},...
    {'CubeRD',0,22,0},...
    {'Goss',0,45,0},...
    {'Copper',90,30,45},...
    {'Copper2',270,30,45},...
    {'SR',53,35,63},...
    {'SR2',233,35,63},...
    {'SR3',307,35,27},...
    {'SR4',127,35,27},...
    {'Brass',35,45,0},...
    {'Brass2',325,45,0},...
    {'PLage',65,45,0},...
    {'PLage2',295,45,0},...
    {'QLage',65,20,0},...
    {'QLage2',245,20,0},...
    {'QLage3',115,160,0},...
    {'QLage4',295,160,0},...
    {'invGoss',90,45,0}};
  
  names = cellfun(@(x) x{1},orientationList,'uniformOutput',false);
  phi1  = cellfun(@(x) x{2},orientationList) * degree;
  Phi   = cellfun(@(x) x{3},orientationList) * degree;
  phi2  = cellfun(@(x) x{4},orientationList) * degree;
    
end
