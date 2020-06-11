%% Gateway to validation scripts
%
% v_piISET
%
% Some tutorials, some scripts, some other validation programs.  The
% validations in this script should not involve any calculations that
% require using Flywheel or Google Cloud.
%
% There is another validation script, v_piCloud, that should check those
% functions.
%
% ZL,BW
%
% See also
%   v_piCloud


%% TODO - 
%{

% Tests fluorescence.  Needs to be fixed for seeing 'eem' values including 
% Donaldson and concentration variables.
t_piIntro_macbeth_fluorescent;   

%  Not sure what to do here.
piTextureAssignToMaterial % needs fixing by ZLy

%}

disp('Check v_pi to see work that still needs doing')

%%

t_piIntro_macbeth;               % Gets the depth map

%%
t_piIntro_macbeth_zmap;          % Get the zmap

%%  Check that the scenes in the data directory still run

v_piDataScenes;                  % Checks the local data scenes

%%  Rotate the camera

t_piIntro_cameramotion

%% Maybe redundant with prior cameramotion

t_piIntro_cameraposition

%% Try a lens

t_piIntro_fisheyelens;

%%  Change the lighting

t_piIntro_light

%%  Glass, mirrors ...

t_piIntro_material

%% It runs, but we are not happy

t_piIntro_meshLabel

%%  Not clearly needed, but it is fast

t_skymapDaylight

%% END