function [pbrtFile,rigOrigin] = selectBitterliScene(sceneName)
%SELECTBITTERLISCENE Keep track of PBRT scene file locations and good 360
%rig locations here. These scenes are all from Benedikt Bitterli
%(https://benedikt-bitterli.me/resources/) but modified to include more
%lights and to be compatible with the pbrt2ISET parser. The rig origin
%locations were chosen manually by me; they tend to be near the center of
%the room at roughly 5-6 ft above the ground.

% Hard coded for now.
sceneDir = '/sni-storage/wandell/users/tlian/360Scenes/scenes';

if(~exist(sceneDir,'dir'))
    error(sprintf('Scene directory "%s" not found. \n The scenes modified scenes are kept in tlian''s data directory at the moment, but will eventually be moved up to the archiva server for anyone to download.',sceneDir))
end

switch sceneName
    case('whiteRoom')
        pbrtFile = fullfile(sceneDir,'living-room-2','scene.pbrt');
        rigOrigin = [0.9476 1.3018 3.4785] + [0 0.600 0];
    case('livingRoom')
        pbrtFile = fullfile(sceneDir,'living-room','scene.pbrt');
        rigOrigin = [2.7007    1.5571   -1.6591];
    case('bathroom')
        pbrtFile = fullfile(sceneDir,'bathroom','scene.pbrt');
        rigOrigin = [0.3   1.667   -1.5];
    case('kitchen')
        pbrtFile = fullfile(sceneDir,'kitchen','scene.pbrt');
        rigOrigin = [0.1768    1.7000   -0.2107];
    case('bathroom2')
        pbrtFile = fullfile(sceneDir,'bathroom2','scene.pbrt');
        rigOrigin = [];
    case('bedroom')
        pbrtFile = fullfile(sceneDir,'bedroom','scene.pbrt');
        rigOrigin = [1.1854    1.1615    1.3385];
    otherwise
        error('Scene not recognized.');
end

if(isempty(rigOrigin))
    warning('Rig origin not set for this scene yet.')
end

end

