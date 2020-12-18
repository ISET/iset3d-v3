function [vLineHandleTree, hLineHandleTree, textHandleTree] = plot(obj, heightTree, varargin)
%% PLOT  Plot the tree.
% 
%   PLOT(T) lay out the tree T on new axes, complying to Edward Tufte
%   recommandations.
%
%   PLOT(T, LT), where LT is a synchronized tree made of scalars, lay out
%   the tree, using LT data to specify the length of each vertical branch.
%   Use the empty array [] to use a default of 1 for all branches.
%
%   PLOT(T, LT, 'PropertyName', PropertyValue, ...) allows to specify extra
%   parameters for the plot:
%
%       'Ylabel' - a string or a cell array of strings: Use a label for the
%       Y axis. The axis itself becomes visible and ticks are drawn on the
%       tree.
%
%       'X' - a scalar: X leftmost position of the tree.
%
%       'Width' - a scalar: Width of the whole tree or of each branch (see
%       'NormalizeWidth')
%
%       'NormalizeWidth' - a boolean, default is false. If true, then the
%       tree total width will be adjusted so that it spans over the 'Width'
%       value. Otherwise, each branch will have a width set by this 'Width'
%       value.
%
%       'TextRotation' - a scalar: Rotation, in degrees, of the label that
%       is printed above each node.
%
%       'Parent - an axes handle: The axes handle to plot the tree in. The
%       axes are not changed, except for the YLabel.
%
%       'Sorted' - a boolean value: If true, the chlid nodes will be sorted
%       when meeting a branching point.
%
%       'DrawLabels' - a boolean value: If true (the default), the node
%       content of the specified tree will be printed next to each branch.
%
%   [ VL HL TH ] = PLOT(T, ...) returns three synchronized trees containing
%   respectively the handles for the vertical lines, the horizontal lines
%   and the text labels of each node.
%
%   EXAMPLE:
%   [ lineage duration ] = tree.example; % 1st one is made of strings only, 2nd one of integers
%   slin = lineage.subtree(19); % Work on a subset
%   sdur = duration.subtree(19);
%   [vlh hlh tlh] = slin.plot(sdur, 'YLabel', {'Division time' '(min)'});
%   rcolor = [ 0.6 0.2 0.2 ];
%   aboveTreshold = sdur > 10; % true if longer than 10 minutes
%   iterator = aboveTreshold.depthfirstiterator;
%   for i = iterator
%    if  aboveTreshold.get(i)
%        set( vlh.get(i), 'Color' , rcolor )
%        set( hlh.get(i), 'Color' , rcolor )
%        set( tlh.get(i), 'Color' , rcolor )
%    end
% end

% Jean-Yves Tinevez <tinevez AT pasteur DOT fr> March 2012

    %% CONSTANTS
    
    LINE_COLOR = [ 0.3 0.3 0.3 ];
    
    %% Deal with input
    
    if nargin < 2 || isempty(heightTree)
        heightTree = tree(obj, 1);
    end
    
    % Force lower case, allow spaces
    varargin = ieParamFormat(varargin);
    
    parser = inputParser;
    parser.addParameter('ylabel', [], @(x) ischar(x) || iscell(x));
    parser.addParameter('textrotation', 0, @(x) isnumeric(x) && isscalar(x) );
    parser.addParameter('parent', [], @ishandle);
    parser.addParameter('x', 0, @(x) isnumeric(x) && isscalar(x) );
    parser.addParameter('width', 1, @(x) isnumeric(x) && isscalar(x) );
    parser.addParameter('normalizewidth', false, @(x) islogical(x) && numel(x) == 1 );
    parser.addParameter('sorted', false, @(x) islogical(x) && numel(x) ==1 );
    parser.addParameter('drawlabels', true, @(x) islogical(x) && numel(x) ==1 );
    parser.addParameter('fontsize', 11, @isnumeric);
    parser.addParameter('fontname', 'Georgia', @ischar);

    parser.parse(varargin{:});
    ylbl    = parser.Results.ylabel;
    textrot = mod(parser.Results.textrotation, 360);
    ax      = parser.Results.parent;
    xcorner = parser.Results.x;
    xwidth  = parser.Results.width;
    normalizewidth = parser.Results.normalizewidth;
    sorted  = parser.Results.sorted;
    drawlabels = parser.Results.drawlabels;
    fontsize = parser.Results.fontsize;
    fontname = parser.Results.fontname;

    %% Compute the column width
    
    width = tree(obj, 'clear');

    % Put 1 at the leaves
    iterator = obj.depthfirstiterator(1, true);
    for i = iterator
       if width.isleaf(i)
           width = width.set(i, 1);
       end
    end
    
    % Cumsum
    width = width.recursivecumfun(@sum);
    
    % Normalize
    if normalizewidth
        maxWidth = width.get(1);
        width = width .* ( xwidth / maxWidth );
    else 
        width = width .* xwidth ;
    end
    
    %% Compute the X *column* width
    % The heavy part on arranging node in sorted order or not is done here.
    
    xcol = tree(width, 'clean');
    xcol = xcol.set(1, 0);
    
    if sorted
        
        iterator = obj.depthfirstiterator(1, true);
        for i = iterator
           
            if i == 1
                previous = 0;
            else
                previous = xcol.get( i );
            end
            
            children = obj.getchildren(i);
            contents = obj.Node(children);
            [ ~, sorting_array ] = sortrows(contents);
            children = children(sorting_array);
            
            for c = children
               xcol = xcol.set(c, previous);
               previous = previous + width.get(c);
            end
            
        end
    
    else
        
        previous = 0;
        parent = 1;
        iterator = obj.breadthfirstiterator(false);
        
        for i = iterator(2 : end) % The root is already done
            
            newParent = xcol.getparent(i);
            if newParent ~= parent
                % We just changed branch
                parent = newParent;
                previous = xcol.get(parent);
            end
            
            w = width.get(i);
            xcol = xcol.set(i, previous);
            
            previous = previous + w;
        end
    end
    
    %% Compute the actual X position
  
    xpos = tree(width, 'clean');
    xpos = xpos.set(1, 1);
    iterator = obj.breadthfirstiterator(sorted);
    for i = iterator
        xpos = xpos.set(i, xcol.get(i) + width.get(i)/2);
    end
    
    % Max of x position
    maxXpos = -1;
    for i = iterator
        xp = xpos.get(i);
        if xp > maxXpos
            maxXpos = xp;
        end
    end
    
    
    %% Compute the Y position
    
    ypos = tree(obj, 'clear');
    ypos = ypos.set(1, heightTree.get(1));
    iterator = obj.depthfirstiterator(1, sorted);
    iterator(1) = []; % Skip the root
    
    maxHeight = heightTree.get(1);
    
    for i = iterator
       parent = ypos.getparent(i);
       parentPos = ypos.get(parent);
       height = heightTree.get(i);
       ypos = ypos.set(i, parentPos + height);
       
       if maxHeight < parentPos + height
           maxHeight = parentPos + height;
       end
    end
    
    %% Prepare the axes
    
    if isempty(ax) 
        ax = axes( ...
            'FontName', 'Courier new', ...
            'FontSize', fontsize, ...
            'Color', 'none', ...
            'YDir', 'reverse', ...
            'TickDir', 'out', ...
            'XTickLabel', '', ...
            'XTick', [], ...
            'XLim', [0 maxXpos * 1.05]);
    end
    
    if isempty(ylbl)
        set(ax, ...
            'YTick', [], ...
            'YTickLabel', '')
    else
        ylabel(ylbl, ...
            'HorizontalAlignment', 'right', ...
            'Rotation', 0)
    end
    hold(ax, 'on')
    
    %% A first iteration for the vertical bars
        
    % Prepare holder for the vertical line handles
    vLineHandleTree = tree(obj, 'clear');
    
    iterator = obj.depthfirstiterator(1, sorted);
    for i = iterator
        
        % Vertical bars -> to parent
        
        y1 = ypos.get(i);
        
        if isempty(y1)
            continue
        end
        
        y2 = y1 - heightTree.get(i);
        
        x1 = xpos.get(i) + xcorner;
        x2 = x1;
        
        hl = line([x1 x2], [y1 y2], ...
            'Color', LINE_COLOR, ...
            'LineWidth', 1);
        
        vLineHandleTree = vLineHandleTree.set(i, hl);
        
    end
    
    
    %% New iteration for the bars and the content
        
    % Prepare the holder for the text handles
    textHandleTree = tree(obj, 'clear');
    
    % Prepare the holder for horizontal line handles
    hLineHandleTree = tree(obj, 'clear');
    
    % Prepare display of text
    if textrot <  45 || (textrot >  135 && textrot < 225) || textrot > 315
        halign = 'center';
        valign = 'middle';
        contentfun = @(x) { x ' ' ' ' };
    else
        halign = 'left';
        valign = 'middle';
        contentfun = @(x) [ ' ' x ];
    end
    
    for i = iterator
        
        y1 = ypos.get(i);
        if isempty(y1)
            continue
        end
        
        x1 = xpos.get(i) + xcorner;
        
        % Alternate y value a bit across x values to allow for long names
        if isodd(round(x1)), delta =  0.0;
        else,                delta = -0.2;
        end
        y2 = y1 - heightTree.get(i) + delta;
        
        if drawlabels
            
            % The label = content
            content = obj.get(i);
            if isempty(content)
                content = 'ø';
            end
            if ~ischar(content)
                content = num2str(content);
            end
            
            % A hack to have text displayed above bars
            ht = text(x1, y2, contentfun(content), ...  
                'HorizontalAlignment', halign,...
                'Rotation', textrot, ...
                'VerticalAlignment', valign, ...
                'FontName', fontname, ...
                'Interpreter', 'none', ...
                'FontSize', fontsize);
            
            textHandleTree = textHandleTree.set(i, ht);
            
        end
        
        % Horizontal bars -> children
        if obj.isleaf(i)
            continue
        end
        
        children = obj.getchildren(i);
        allX = cell2mat(xpos.Node(children)) + xcorner;
        
        y2 = y1;
        x1 = min(allX);
        x2 = max(allX);
        
        if numel(children) > 1
            hl = line([x1 x2], [y1 y2], ...
                'Color', LINE_COLOR, ...
                'LineWidth', 5);
        else
            hl = line(x1, y1 + delta, ...
                'Color', LINE_COLOR, ...
                'Marker', '.', ...
                'MarkerSize', 14);
            
        end
        
        hLineHandleTree = hLineHandleTree.set(i, hl);
        
    end
    
    
    % If we were given a height tree, draw white ticks on the tree, a la
    % Tufte.

    if nargin >= 2
        tree.decorateplots(ax);
    end
    
end