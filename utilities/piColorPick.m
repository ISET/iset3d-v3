function rgb = piColorPick(color)
%% choose a pre-defined color or randomly pick one
if contains(color,'random')
    colorlist = {'white','black','red',...
        'blue','silver',''};
    index = rand;
%     color = colorlist{index};
if index  <= 0.3, color = 'white';end
if index>0.3&&index<=0.5, color = 'black';end
if index>0.5&&index<=0.65, color = 'red';end
if index>0.65&&index<=0.8, color = 'blue';end
if index>0.8&&index<=0.85, color = 'green';end
if index>0.85&&index<=0.90, color = 'yellow';end
if index>0.90&&index<=1, color = 'silver';end
     rgb = colorswitch(color);
else
    rgb = colorswitch(color);
end
end

function rgb = colorswitch(color)
switch color
    case 'brown'
        r = 100;
        g = r - 20;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'white'
        r = 250;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'black'
        r = 10;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'red'
        r = 220;
        g = 1;
        b = 1;
        rgb = [r/255 g/255 b/255];
    case 'blue'
        r = 1;
        b = 220;
        g = 1;
        rgb = [r/255 g/255 b/255];
    case 'green'
        g = 108;
        r = 11;
        b = 91;
        rgb = [r/255 g/255 b/255];
    case 'yellow'
        r = 249;
        g = 184;
        b = 68;
        rgb = [r/255 g/255 b/255];
    case 'silver'
        r = 179;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'grey'
        r = 104;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
end
end