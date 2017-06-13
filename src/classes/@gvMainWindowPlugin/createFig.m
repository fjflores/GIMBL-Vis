function createFig(pluginObj)

mainWindowHandle = figure(...
  'Units','pixels',...
  'Position',[29 778 567 567],...
  'MenuBar','none',...
  'Name',pluginObj.windowName,...
  'NumberTitle','off',...
  'Tag','mainWindow',...
  'UserData',pluginObj.userData...
);

% Set Handle
pluginObj.handles.fig = mainWindowHandle;

end