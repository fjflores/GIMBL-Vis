function openLegendWindow(viewObj)

mainWindowExistBool = viewObj.checkMainWindowExists;

if mainWindowExistBool && ~isValidFigHandle(viewObj.legendWindow.windowHandle)
  createLegendWindow(viewObj);
  
  hcData = viewObj.activeHypercube;
  
  colors = cat(1,handles.PlotWindow.Label.colors{:});
  markers = handles.PlotWindow.Label.markers;
  groups = handles.PlotWindow.Label.names;
  nGroups = length(groups);
  
  itemSize = 16;
  
  %Make Legend
  hold on
  h = zeros(nGroups, 1);
  for iG = 1:nGroups
%     h(iG) = plot(nan,nan,'Color',colors(iG,:),'Marker',markers{iG});
    h(iG) = scatter(nan,nan,itemSize,colors(iG,:),markers{iG});
  end
  
  [leg,labelhandles] = legend(h, groups, 'Position',[0 0 1 1], 'Box','off', 'FontSize',20, 'Location','West');
  objs = findobj(labelhandles,'type','Patch');
  [objs.MarkerSize] = deal(itemSize);
  objs = findobj(labelhandles,'type','Text');
  [objs.FontSize] = deal(itemSize);
end

  %% Nested Functions
  function createLegendWindow(viewObj)
    mainWindowPos = viewObj.mainWindow.windowHandle.Position;
    ht = 30 * length(handles.PlotWindow.Label.names);
    legendWindowHandle = figure('Name','Legend Window','NumberTitle','off','menubar','none',...
      'Position',[mainWindowPos(1),max(mainWindowPos(2)-ht-50, 0),250,ht]);
    
    axes(legendWindowHandle, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
      'XTick',[], 'YTick',[]);
    
    % set legend windowHandle
    viewObj.legendWindow.windowHandle = legendWindowHandle;
  end

end