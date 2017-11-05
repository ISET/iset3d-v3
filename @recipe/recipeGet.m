function val = recipeGet(thisR,param,varargin)
% Derive parameters from the recipe class
%
%     recipe.get(param,...)
%
% Syntax:
%     val = recipeGet(thisR,param,varargin)
%
% Inputs:
%     thisR - a recipe object
%     param - a parameter (string)
%
% Returns
%     val - derived parameter
%
% BW, ISETBIO Team, 2017

% Examples
%{
  val = thisR.get('object distance');
  val = thisR.get('focal distance');
  val = thisR.get('camera type');
%}

% Programming todo
%

%%
if isequal(param,'help')
    doc('recipe.recipeGet');
    return;
end

p = inputParser;
vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('param',@ischar); 

p.parse(thisR,param,varargin{:});

param = ieParamFormat(param); 

switch param

        % Scene
    case 'objectdistance'
        diff = thisR.lookAt.from - thisR.lookAt.to;
        val = sqrt(sum(diff.^2));
    case 'objectdirection'
        % A unit vector in the lookAt direction
        val = thisR.lookAt.from - thisR.lookAt.to;
        val = val/norm(val);
    case 'fromto'
        val = thisR.lookAt.from - thisR.lookAt.to;

        % Camera
    case 'opticstype'
        % perspective means pinhole.  Maybe we should rename.
        % realisticDiffraction means lens.  Not sure of all the possibilities
        % yet.
        val = thisR.camera.subtype;
        if isequal(val,'perspective'), val = 'pinhole';
        elseif ismember(val,{'realisticDiffraction'})
            val = 'lens';
        end
    case 'focaldistance'
        opticsType = thisR.get('optics type');
        switch opticsType
            case {'pinhole','perspective'}
                disp('Pinhole optics.  No focal distance');
                val = NaN;
            case 'lens'
                % Focal distance given the object distance and the lens file
                [p,flname,~] = fileparts(thisR.camera.specfile.value);
                focalLength = load(fullfile(p,[flname,'.FL.mat']));
                objDist = thisR.get('object distance');
                val = interp1(focalLength.dist,focalLength.focalDistance,objDist);
            otherwise
                error('Unknown camera type %s\n',opticsType);
        end
    case 'nmicrolens'
        % How many microlens (pinholes)
        val(2) = thisR.camera.num_pinholes_w.value;
        val(1) = thisR.camera.num_pinholes_h.value;

    case 'nsubpixels'
        % How many film pixels behind each microlens/pinhole
        val(2) = thisR.camera.subpixels_w;
        val(1) = thisR.camera.subpixels_h;
        
    otherwise
        error('Unknown parameter %s\n',param);
end

end