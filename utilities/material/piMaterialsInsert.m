function [thisR, materialNames] = piMaterialsInsert(thisR)
% Insert default materials for the recipe
%
% Synopsis
%  [thisR. materialNames] = piMaterialsInsert(thisR)
%
% We will add functionality here over time.  Just a placeholder for now.
%
% See also
%   piTexturesInsert

%% Need variable checking


materialNames = {};

%%

% Turn the letter A to Glass material
glassName = 'glass'; glassMat = piMaterialCreate(glassName, 'type', 'glass');
thisR.set('material', 'add', glassMat);
materialNames{end+1} = glassName;

% Make a new material like White, but color it red
RedName = 'Red'; RedMat = piMaterialCreate(RedName, 'type', 'uber');
RedMat = piMaterialSet(RedMat,'kd',[1 0.3 0.3]);
thisR.set('material', 'add', RedMat);
materialNames{end+1} = RedName;

% Make a new material like White, but color it red
WhiteName = 'Red'; whiteMat = piMaterialCreate(WhiteName, 'type', 'uber');
whiteMat = piMaterialSet(whiteMat,'kd',[1 1 1]);
thisR.set('material', 'add', whiteMat);
materialNames{end+1} = WhiteName;

% Make a new material like White, but color it gray
GrayName = 'Gray'; GrayMat = piMaterialCreate(GrayName, 'type', 'uber');
GrayMat = piMaterialSet(GrayMat,'kd',[0.1 0.1 0.1]);
thisR.set('material', 'add', GrayMat);
materialNames{end+1} = GrayName;

% Make a new material like White, but make it specular/shiny
ShinyName = 'Shiny'; ShinyMat = piMaterialCreate(ShinyName, 'type', 'uber');
ShinyMat = piMaterialSet(ShinyMat,'kd',[0.7 0.7 0.7]);
ShinyMat = piMaterialSet(ShinyMat,'ks',[1 1 1]);
ShinyMat = piMaterialSet(ShinyMat,'roughness',1);
thisR.set('material', 'add', ShinyMat);
materialNames{end+1} = ShinyName;

mirrorName = 'mirror';
mirrorMat = piMaterialCreate(mirrorName, 'type', 'mirror');
thisR.set('material', 'add', mirrorMat);
materialNames{end+1} = mirrorName;

end