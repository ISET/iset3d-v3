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

p = inputParser;
vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('param',@ischar); 

if isequal(param,'help')
    % Maybe something else here?
    doc('recipe.recipeGet');
    return;
end

p.parse(thisR,param,varargin{:});

param = ieParamFormat(param); 

switch param

    case 'opticstype'
        % perspective means pinhole.  Maybe we should rename.
        % lens means lens.
        val = thisR.camera.subtype;
        if isequal(val,'perspective'), val = 'pinhole'; end
    case 'objectdistance'
        diff = thisR.lookAt.from - thisR.lookAt.to;
        val = sqrt(sum(diff.^2));
        
    case 'focaldistance'
        opticsType = thisR.get('camera type');
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
        
    otherwise
        error('Unknown parameter %s\n',param);
end

end