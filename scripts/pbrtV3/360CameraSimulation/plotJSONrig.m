function H = plotJSONrig( jsonFile )

% Plot a Facebook rig based on the rig JSON file. Useful for debugging. 

rig = jsonread(jsonFile);
rig = rig.cameras;

H = figure; hold on; grid on;
xlabel('x');
ylabel('y');
zlabel('z');
s = 5;

for ii = 1:length(rig)
    if(iscell(rig))
        c = rig{ii};
    else
        c = rig(ii);
    end
    
    quiver3(c.origin(1),c.origin(2),c.origin(3), ...
    c.up(1),c.up(2),c.up(3),s,'b');
    quiver3(c.origin(1),c.origin(2),c.origin(3), ...
    c.right(1),c.right(2),c.right(3),s,'r');
    quiver3(c.origin(1),c.origin(2),c.origin(3), ...
    c.forward(1),c.forward(2),c.forward(3),s,'g');

    text(c.origin(1),c.origin(2),c.origin(3),c.id);

end


end

