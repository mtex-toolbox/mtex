%% Documentation
%
%%
% Every picture below opens a chapter. Together they are most of what MTEX
% does: crystal geometry, orientation maps, diffraction data, the
% distributions they are summarised by, and the material properties that
% follow from them.
%
% If you are new, the quickest route in is
% <Tutorials.html Tutorials>, which walks a complete analysis from importing
% a file to a result. <Glossary.html Glossary> and
% <NotationAndConventions.html Notation and Conventions> are worth knowing
% about early - the second collects the choices, such as Euler angle
% convention and reference frame alignment, that quietly decide whether your
% numbers agree with someone else's.
%
%% Start here
%
% How to run MTEX at all, and how to make it draw things.
%
% <html>
%    <div style="display:block;">
%       <a href="Tutorials.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Tutorials.png" alt="Tutorials" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Tutorials</span></a>
%       <a href="GeneralConcepts.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_GeneralConcepts.png" alt="General Concepts" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">General Concepts</span></a>
%       <a href="Plotting.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Plotting.png" alt="Plotting" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Plotting</span></a>
%    </div>
% </html>
%
%% Geometry
%
% Directions, rotations, symmetry, and the orientation of one crystal in one specimen. Everything else is built on these.
%
% <html>
%    <div style="display:block;">
%       <a href="Vectors.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Vectors.png" alt="Vectors" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Vectors</span></a>
%       <a href="Rotations.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Rotations.png" alt="Rotations" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Rotations</span></a>
%       <a href="CrystalGeometry.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_CrystalGeometry.png" alt="Crystal Geometry" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Crystal Geometry</span></a>
%       <a href="CrystalOrientations.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_CrystalOrientations.png" alt="Orientations" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Orientations</span></a>
%       <a href="Misorientations.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Misorientations.png" alt="Misorientations" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Misorientations</span></a>
%    </div>
% </html>
%
%% Orientation maps
%
% Measuring orientations point by point across a surface, and turning the result into grains, boundaries and volumes.
%
% <html>
%    <div style="display:block;">
%       <a href="EBSDAnalysis.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_EBSDAnalysis.png" alt="EBSD" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">EBSD</span></a>
%       <a href="Grains.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Grains.png" alt="Grains" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Grains</span></a>
%       <a href="GrainBoundaries.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_GrainBoundaries.png" alt="Grain Boundaries" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Grain Boundaries</span></a>
%       <a href="EBSD3Analysis.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_EBSD3Analysis.png" alt="3D - EBSD" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">3D - EBSD</span></a>
%    </div>
% </html>
%
%% Texture
%
% Describing a whole population of orientations rather than one crystal, and the mathematics that makes it computable.
%
% <html>
%    <div style="display:block;">
%       <a href="PoleFigureAnalysis.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_PoleFigureAnalysis.png" alt="Pole Figures" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Pole Figures</span></a>
%       <a href="ODFAnalysis.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_ODFAnalysis.png" alt="ODF" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">ODF</span></a>
%       <a href="SphericalFunctions.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_SphericalFunctions.png" alt="Spherical Functions" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Spherical Functions</span></a>
%       <a href="SO3Functions.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_SO3Functions.png" alt="Orientation Functions" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Orientation Functions</span></a>
%    </div>
% </html>
%
%% Material properties
%
% What the texture implies for how the material behaves - how stiff it is, how sound travels through it, how it deforms and how it transforms.
%
% <html>
%    <div style="display:block;">
%       <a href="Tensors.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Tensors.png" alt="Tensors" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Tensors</span></a>
%       <a href="Elasticity.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Elasticity.png" alt="Elasticity" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Elasticity</span></a>
%       <a href="Plasticity.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_Plasticity.png" alt="Plasticity" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Plasticity</span></a>
%       <a href="PhaseTransitions.html" style="width:150px;margin:0 14px 18px 0;text-decoration:none;color:inherit;display:inline-block;vertical-align:top;"><img src="images/chapter_PhaseTransitions.png" alt="Phase Transitions" style="width:150px;height:150px;display:block;border:1px solid #d0d0d0;border-radius:4px;"><span style="display:block;margin-top:6px;text-align:center;line-height:1.25;">Phase Transitions</span></a>
%    </div>
% </html>
%
%% These pages are scripts
%
% Every page here is an executable MATLAB script, and you have a copy of it
% in your MTEX installation. The file name is the last part of the URL with
% |.html| swapped for |.m|, so this page is |Documentation.m| and you can
% open it with
%
%   edit Documentation
%
% Run a page section by section, change the numbers, and see what depends on
% what. That is the fastest way to learn what a command actually does, and
% these scripts are a reasonable starting point for your own.
%
%% Contributing
%
% Documenting a project like MTEX is an ongoing job, so corrections,
% examples and explanations are all welcome, and everybody who contributes
% appears on the
% <https://github.com/mtex-toolbox/mtex/graphs/contributors contributors
% page>.
%
% The easiest route is through GitHub: sign in, open the page you want to
% change, click *edit page* at the top to reach the file, then the pencil
% icon to edit it in the browser. *Propose changes* and *create pull
% request* at the bottom send it to us. You may also simply
% <mailto:ralf.hielscher@mathematik.tu-chemnitz.de email> the change.
%
% To preview a page you have altered, use the MATLAB
% <https://de.mathworks.com/help/matlab/matlab_prog/publishing-matlab-code.html publish>
% command, which writes an |html| folder next to it:
%
%   publish filename
%
