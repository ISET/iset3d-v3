function rgb = piColorPick(color,varargin)
% Choose a pre-defined color or randomly pick one of the list
%
% Syntax
%  rgb = piColorPick(color,varargin)
%
% Description
%   For the moment, there is randomization of the returned color.  We
%   get something in the range.  We are going to create a key/value
%   pair that sets the randomization range or that turns off
%   randomization of the returned color.
%
% Inputs
%    color:  'red','blue','white','black','silver','yellow','random'
%
% Key/value pairs
%     N/A yet
%
% Outputs
%   rgb - red green blue triplet
%
% Zhenyi
%
% See also
%   piMaterialAssign
%


%% Parse

% colorlist = {'white','black','red','blue','silver','yellow'};

%%

if piContains(color,'random')
    % Choose a random color, I guess.
    index = rand;
    
    if index <= 0.25, color = 'white';end
    if index > 0.25 && index <= 0.45, color = 'black';end
    if index > 0.45 && index <= 0.61, color = 'gray';end
    if index > 0.61 && index <= 0.71, color = 'red';end
    if index > 0.71  && index <= 0.79, color = 'blue';end
    if index > 0.79 && index <= 82, color = 'green';end
    if index > 0.82 && index <= 0.85, color = 'yellow';end
    if index > 0.85 && index <= 0.99, color = 'silver';end
    if index > 0.99 && index <= 1.00, color = 'random';end
    rgb = colorswitch(color);
else
    rgb = colorswitch(color);    
end

end

function rgb = colorswitch(color)
switch color
    case 'white'
        r = 240+randi([0,15],1);
        g = 240+randi([0,15],1);
        b = 240+randi([0,15],1);
    case 'black'
        r = 15+randi([0,20],1);
        g = r;
        b = r;
    case 'gray'
        r = 169+rand(1);
        g = 169+rand(1);
        b = 169+rand(1);
    case 'red'
        r = 134+rand(1);
        g = 1+rand(1);
        b = 17+rand(1);        
    case 'blue'
        r = 22+rand(1);
        g = 54+rand(1);
        b = 114+rand(1);
    case 'green'
        r = 84+rand(1);
        g = 128+rand(1);
        b = 66+rand(1);
    case 'yellow'
        r = 223+rand(1);
        g = 192+rand(1);
        b = 99+rand(1);
    case 'silver'
        r = 192+rand(1);
        g = r;
        b = g;
    case 'random'
        r = randi([0,255],1);
        g = randi([0,255],1);
        b = randi([0,255],1);  
end
rgb = [r/255 g/255 b/255];
end