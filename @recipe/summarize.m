function [out, namelist] = summarize(thisR,str)
% Summarize the recipe 
%
% Syntax
%   [out, namelist] = recipe.summarize(str)
%
% Description
%   Prints a summary of the PBRT recipe parameters to the console. This
%   routine has a lot of options.  We might simplify them or at least make
%   the default more useful.  Have a look at sceneEye.summary().
%
% Inputs
%   str:  'all','file','render','camera','film',lookat','assets',
%         'materials',or 'metadata' 
%
% Key/value pairs
%   N/A
%
% Outputs:
%   out  - Either the object described our empty
%   namelist - If str = 'assets', a sorted list of the names of the assets,
%              or if str = 'materials' the names of the materials
%
% Description
%    A quick summary of the critical rendering recipe parameters. In
%    several cases the object described is returned
%
% Wandell
%
% See also
%  sceneEye.summary, recipe, recipeGet
%

% Examples:
%{
 c = thisR.summarize('camera');
%}
%{
 [assets, sortedNames] = thisR.summarize('assets');
  sortedNames
%}
%{
 [~,sortedNames] = thisR.summarize('all');
%}
%% Parse

validStr = {'all','file','render','camera','film','lookat','assets','materials','metadata'};
p = inputParser;
p.addRequired('thisR',@(x)(isequal(class(x),'recipe')));
p.addRequired('str',@(x)(ismember(x,validStr)));

% Default for str is 'all'.  Force to lower case.
if ~exist('str','var'),str = 'all'; end
str = ieParamFormat(str);

p.parse(thisR,str);

namelist = [];
out = [];
%% Build descriptions

switch str
    case 'all'
        thisR.summarize('file');
        thisR.summarize('render');
        thisR.summarize('camera');
        thisR.summarize('film');
        thisR.summarize('lookat');
        [~,namelist] = thisR.summarize('assets');
        thisR.summarize('materials');
        thisR.summarize('metadata');
    case 'file'
        fprintf('\nFile information\n-----------\n');
        fprintf('Input:  %s\n',thisR.get('input file'));
        fprintf('Output: %s\n',thisR.get('output file'));
        if isfield(thisR,'exporter'), fprintf('Exported by %s\n',thisR.exporter); end
        % fprintf('\n');
        
    case 'render'
        fprintf('\nRenderer information\n-----------\n');
        fprintf('Rays per pixel %d\n',thisR.get('rays per pixel'));
        fprintf('Bounces %d\n',thisR.get('n bounces'));
        namelist = thisR.world;  % Abusive.  Change variable name.
        % fprintf('\n');
        
    case 'camera'
        fprintf('\nCamera parameters\n-----------\n');
        if isempty(thisR.camera), return; end
        out = thisR.camera;
        
        fprintf('Sub type: %s\n',thisR.camera.subtype);
        fprintf('Lens file name:   %s\n',thisR.get('lens file'));
        fprintf('Aperture diameter (mm): %0.2f\n',thisR.get('aperture diameter'));
        fprintf('Focal distance (m):\t%0.2f\n',thisR.get('focal distance'));
        fprintf('Exposure time (s):\t%f\n',thisR.get('exposure time'));
        fprintf('Field of view (deg):\t%f\n',thisR.get('fov'));
        % fprintf('\n');
        
    case 'film'
        out = thisR.film;
        fprintf('\nFilm parameters\n-----------\n');
        fprintf('subtype: %s\n',out.subtype);
        fprintf('x,y resolution: %d %d (samples)\n',round(thisR.get('film resolution')));
        lensFile = thisR.get('lens file');
        if isequal(lensFile,'pinhole (perspective)')
            % We should do something smart here.  This is not smart.
        else
            fprintf('diagonal:   %d (mm)\n',thisR.get('film diagonal'));
        end
        % fprintf('\n');
        
    case 'lookat'
        fprintf('\nLookat parameters\n-----------\n');
        if isempty(thisR.lookAt), return; end
        out = thisR.lookAt;
        fprintf('from:\t%.3f %.3f %.3f\n',thisR.get('from'));
        fprintf('to:\t%.3f %.3f %.3f\n',thisR.get('to'));
        fprintf('up:\t%.3f %.3f %.3f\n',thisR.get('up'));
        fprintf('object distance: %.3f (m)\n',thisR.get('object distance'));
        % fprintf('\n');
        
    case 'assets'
        if isempty(thisR.assets)
            fprintf('\nNo assets \n-----------\n');
            return;
        else
            try
                thisR.show('objects');
            catch
            end
        end
                
    case 'materials'
        if isempty(thisR.materials)
            fprintf('\nNo materials \n-----------\n');
            return;
        else
            try
                thisR.show('objects');
            catch
            end
        end
        
    case 'metadata'

        fprintf('\nMetadata\n-----------\n');
        if isempty(thisR.metadata), return; end
        out = thisR.metadata;

        namelist = fieldnames(thisR.metadata);
        fprintf('Fields:\n');
        for ii=1:numel(namelist)
            fprintf('%d\t%s\n',ii,namelist{ii});
        end
        % fprintf('\n');
        
    otherwise
        error('Unknown parameter %s\n',str);
end

end