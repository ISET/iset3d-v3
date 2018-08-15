function rgb = piColorPick(color)
%% choose a pre-defined color or randomly pick one
if contains(color,'random')
    colorlist = {'brown','white','black','red',...
        'grey','blue','green','yellow','silver'};
    index = rand;
%     color = colorlist{index};
if index  < 0.15, color = 'white';end
if index>0.15&&index<0.3, color = 'black';end
if index>0.3&&index<0.45, color = 'silver';end
if index>0.45&&index<0.55, color = 'grey';end
if index>0.55&&index<0.65, color = 'red';end
if index>0.65&&index<0.75, color = 'green';end
if index>0.75&&index<0.85, color = 'blue';end
if index>0.85&&index<0.9, color = 'yellow';end
if index>0.9&&index<1, color = 'brown';end
    rgb = colorswitch(color);
else
    rgb = colorswitch(color);
end
end

function rgb = colorswitch(color)
switch color
    case 'brown'
        r = randi([80,150]);
        g = r - 20;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'white'
        r = randi([245,255]);
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'black'
        r = randi([0,60]);
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'red'
        r = randi([133,255]);
        g = r-130;
        b = r-130;
        rgb = [r/255 g/255 b/255];
    case 'grey'
        r = randi([150,200]);
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'blue'
        r = randi([0,4]);
        b = randi([100 255]);
        g = b-50;
        rgb = [r/255 g/255 b/255];
    case 'green'
        g = randi([80,255]);
        r = g-80;
        b = r();
        rgb = [r/255 g/255 b/255];
    case 'yellow'
        r = 255;
        g = randi([180,255]);
        b = g-80;
        rgb = [r/255 g/255 b/255];
    case 'silver'
        r = randi([200,230]);
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
end
end