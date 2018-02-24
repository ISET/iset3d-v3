function [materiallib] = piMateriallib
% A library of materials stored in the materials struct fields
%
%  The material properties included here are designed to be assigned
%  to an existing material, not replace the entire material.
%  Typically, we read a material and if we want it to look like, say
%  carpaint, we assign the materiallib.carpaint properties to the
%  material.
%
% ZL Scien Stanford, 2018

% Examples:
%{
  
%}
%% carpaintmix
%
% A mixture of a specular (mirror like) material and a substrate
% material that looks like a car.

materiallib.carpaintmix.paint_mirror.string = 'mirror';
materiallib.carpaintmix.paint_mirror.rgbkr = [.1 .1 .1];
materiallib.carpaintmix.paint_base.string='substrate';
materiallib.carpaintmix.paint_base.colorkd = [.7 .125 .125];
materiallib.carpaintmix.paint_base.colorks =[.1 .1 .1];
materiallib.carpaintmix.paint_base.floaturoughness=0.01;
materiallib.carpaintmix.paint_base.floatvroughness=0.01;
materiallib.carpaintmix.carpaint.string = 'mix';
materiallib.carpaintmix.carpaint.stringnamedmaterial1 = 'paint_mirror';
materiallib.carpaintmix.carpaint.stringnamedmaterial2='paint_base';

%% carpaint
%
% Typical car paint without much specularity.  Some people define it
% this way rather than as carpaintmix.
%

materiallib.carpaint.floaturoughness =0.0005;
materiallib.carpaint.floatvroughness=0.00051;
materiallib.carpaint.string='substrate';

%% chrome_spd
%
% This the chrome metal appearance.
%
materiallib.chrome_spd.floatroughness=0.01;
materiallib.chrome_spd.string='metal';
materiallib.chrome_spd.spectrumkd='spds/metals/Al.k.spd';
materiallib.chrome_spd.spectrumks='spds//metals/Al.eta.spd';

%% blackrubber
%
% Good for tires
%
materiallib.blackrubber.floatroughness = 0.5;
materiallib.blackrubber.string = 'uber';
materiallib.blackrubber.rgbkd = [ .01 .01 .01 ];
materiallib.blackrubber.rgbks = [ 0.2 .2 .2 ];

%% mirror
materiallib.mirror.string='mirror';
materiallib.mirror.rgbkr = [0.9 0.9 0.9];

%% matte
% Standard matte surface

materiallib.matte.string = 'matte';
materiallib.matte.rgbkd = [0.7 0.7 0.7];

%% plastic

% Standard plastic appearance
%
materiallib.plastic.string = 'plastic';
materiallib.plastic.rgbkd = [0.25 0.25 0.25];
materiallib.plastic.rgbks = [0.25 0.25 0.25];

%% glass
%
% Standard glass appearance

materiallib.glass.string = 'glass';
materiallib.glass.rgbkr = [0.9 0.9 0.9];
materiallib.glass.rgbkt = [0.9 0.9 0.9];

end




