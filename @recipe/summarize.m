function [out, namelist] = summarize(thisR,str)
% Summarize the recipe entries
%
% Syntax
%   [out, namelist] = recipe.summarize(str)
%
% Description
%   Prints to the console a summary of the recipe parameters.  The string
%   suggests which parameters to emphasize.
%
% Inputs
%   str:  'all','camera','film',lookat','assets', or 'metadata'
%
% Key/value pairs
%   N/A
%
% Outputs:
%   N/A
%
% A utility to improve the quality of programming life by printing to the
% console a quick and clear look at the critical rendering recipe
% parameters.
%
% Wandell
%
% See also
%  recipe
%

% Examples:
%{
 c = thisR.summarize('camera');
%}
%{
 [assets, names] = thisR.summarize('assets');
%}
%{
 [~,names] = thisR.summarize('all');
%}
%% Parse
str = ieParamFormat(str);

validStr = {'all','camera','film','lookat','assets','metadata'};
p = inputParser;
p.addRequired('thisR',@(x)(isequal(class(x),'recipe')));
p.addRequired('str',@(x)(ismember(x,validStr)));
p.parse(thisR,str);

namelist = [];
%% Build descriptions

switch str
    case 'all'
        thisR.summarize('camera');
        thisR.summarize('film');
        thisR.summarize('lookat');
        [~,namelist] = thisR.summarize('assets');
        thisR.summarize('metadata');
        out = [];
        
    case 'camera'
        out = thisR.camera;
        fprintf('\nCamera parameters\n-----------\n');
        fprintf('Sub type: %s\n',thisR.camera.subtype);
        fprintf('Lens file name:   %s\n',thisR.get('lens file'));
        fprintf('Aperture diameter (mm): %0.2f\n',thisR.get('aperture diameter'));
        fprintf('Focal distance (m):   %0.2f\n',thisR.get('focal distance'));
        fprintf('Exposure time (s): %f\n',thisR.get('exposure time'));
        fprintf('\n\n');
        
    case 'film'
        out = thisR.film;
        fprintf('\nFilm parameters\n-----------\n');
        fprintf('subtype: %s\n',out.subtype);
        fprintf('x,y resolution: %d %d (samples)\n',thisR.get('film resolution'));
        fprintf('diagonal:   %d (mm)\n',thisR.get('film diagonal'));
        fprintf('\n\n');
        
    case 'lookat'
        out = thisR.lookAt;
        fprintf('\nLookat parameters\n-----------\n');
        fprintf('from:\t%.3f %.3f %.3f\n',thisR.get('from'));
        fprintf('to:\t%.3f %.3f %.3f\n',thisR.get('to'));
        fprintf('up:\t%.3f %.3f %.3f\n',thisR.get('up'));
        fprintf('\n\n');
        
    case 'assets'
        out = thisR.assets;
        nAssets = numel(out);
        fprintf('\nAssets\n-----------\n');
        fprintf('Number:  %d\n',nAssets);
        nMoving = 0;
        for ii=1:nAssets
            if ~isempty(out(ii).motion)
                nMoving = nMoving + 1;
            end
        end    
        fprintf('Moving  assets: %d\n',nMoving);
        fprintf('Static  assets: %d\n',nAssets - nMoving);
        namelist = cell(nAssets,1);
        for ii=1:nAssets
            namelist{ii} = thisR.assets(ii).name;
        end
        namelist = sort(unique(namelist));
        
    case 'metadata'
        out = thisR.metadata;
        fprintf('\nMetadata\n-----------\n');
        
    otherwise
        error('Unknown parameter %s\n',str);
end

end