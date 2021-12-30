%% Write out the letters as loadable assets
%

%% This is where we will save them
assetDir = fullfile(piRootPath,'data','assets');

%% I did hand work to pull out each of the letters separately and position them.

sceneName = 'letters at depth';
thisR = piRecipeDefault('scene name', sceneName);
thisR.show;

for ii=7:-1:2
    thisR.set('asset',ii,'delete');
end
% thisR.show;

thisR.set('asset','Camera_B','delete');
% thisR.show;

thisR.set('asset','001_A_O','delete');
thisR.set('asset','A_B','delete');
% thisR.set('asset', '001_A_O', 'world position', [0 0 1]);
% thisR.show;

% thisR.set('asset','001_B_O','delete');
% thisR.set('asset','B_B','delete');
thisR.set('asset', '001_B_O', 'world position', [0 0 1]);
% thisR.show;

thisR.set('asset','001_C_O','delete');
thisR.set('asset','C_B','delete');
% thisR.set('asset', '001_C_O', 'world position', [0 0 1]);
% thisR.show;

thisR.set('from',[0 0 0]);
thisR.set('to',[0 0 1]);

thisR.show();

%{
% I checked the letters this way
%
l = piLightCreate('distant','type','distant');
thisR.set('light','add',l);
piAssetGeometry(thisR);
thisR.show('objects')
thisR.get('asset','001_A_O','material')
thisR.set('material','White','kd',[0 0 0]);
piWRS(thisR);
%}

%
mergeNode = 'B_B';
oFile = thisR.save(fullfile(assetDir,'letterB.mat'));
save(oFile,'mergeNode','-append');

%% Merge C into the Chess set

% This is an example to test that it worked.

chessR = piRecipeDefault('scene name','chess set');
% Lysse_brikker is light p;ieces
% Mrke brikker must be dark pieces

letterC = piAssetLoad('letterB');
letterC.thisR.show('objects');
letterC.thisR.show;

piRecipeMerge(chessR,letterC.thisR,'node name',letterC.mergeNode);
chessR.show('objects');
% piAssetGeometry(chessR);
chessR.set('asset',letterC.mergeNode,'world position',[0 0.1 -0.2]);
chessR.set('asset',letterC.mergeNode,'scale',ones(1,3)*0.5);
piWRS(chessR,'render type','both');

%%


