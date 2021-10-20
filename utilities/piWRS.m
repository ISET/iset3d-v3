function [obj,results] = piWRS(thisR,varargin)
% Write, render, show radiance image
%
% Write, Render, Show a scene specified by a recipe
%
% Synopsis
%   [isetObj, results] = piWRS(thisR, varargin)
%
% Inputs
%   thisR - A recipe
%
% Optional key/val pairs
%   name  - Scene or OI name
%
% Returns
%   obj - a scene or oi
%   results - The piRender outputs
%
% See also
%   piRender, sceneWindow, oiWindow

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisR',@(x)(isa(x,'recipe')));
p.addParameter('dockerimagename','vistalab/pbrt-v3-spectral:latest',@ischar);
p.addParameter('rendertype','radiance',@ischar);
p.addParameter('name','',@ischar);

p.parse(thisR,varargin{:});
thisDocker = p.Results.dockerimagename;
renderType = p.Results.rendertype;
name = p.Results.name;

%%
piWrite(thisR);

[obj,results] = piRender(thisR,...
    'docker image name',thisDocker, ...
    'render type',renderType);

switch obj.type
    case 'scene'
        if ~isempty(name), obj = sceneSet(obj,'name',name); end
        sceneWindow(obj);
    case 'opticalimage'
        if ~isempty(name), obj = oiSet(obj,'name',name); end
        oiWindow(obj);
end

end