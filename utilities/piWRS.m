function [obj,results] = piWRS(thisR,varargin)
% Write, render, show radiance image
%
% Write, Render, Show a scene specified by a recipe (thisR).
%
% Synopsis
%   [isetObj, results] = piWRS(thisR, varargin)
%
% Inputs
%   thisR - A recipe
%
% Optional key/val pairs
%   'name'  - Set the Scene or OI name
%   'render type' - piRender render type ('radiance' by default)
%   'show'  -  Call a window to show the object (default) and insert it in
%              the vcSESSION database
%   'docker image name' - Specify the docker image
%
% Returns
%   obj     - a scene or oi
%   results - The piRender text outputs
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
p.addParameter('show',true,@islogical);

p.parse(thisR,varargin{:});
thisDocker = p.Results.dockerimagename;
renderType = p.Results.rendertype;
name = p.Results.name;
show = p.Results.show;

%%
piWrite(thisR);

[obj,results] = piRender(thisR,...
    'docker image name',thisDocker, ...
    'render type',renderType);

switch obj.type
    case 'scene'
        if ~isempty(name), obj = sceneSet(obj,'name',name); end
        if show, sceneWindow(obj); end
    case 'opticalimage'
        if ~isempty(name), obj = oiSet(obj,'name',name); end
        if show, oiWindow(obj); end
end

end