function makePlotPanelControls(pluginObj, parentHandle)
%% makePlotPanelControls
%
% Input: parentHandle - handle for uicontrol parent

fontSize = pluginObj.fontSize;
spacing = 2; % px
padding = 2; % px

uiControlsHandles = struct();

% Make 2x2 grid
grid2x2 = uix.Grid('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);

% (1,1)
% openPlotButton
thisTagStr = 'openPlotButton';
uiControlsHandles.openPlotButton = uicontrol(...
'Tag',[pluginObj.pluginFieldName '_panel_' thisTagStr],...
'Style','pushbutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Open Plot',...
'UserData',pluginObj.userData,...
'Callback',@gvPlotWindowPlugin.openWindowCallback,...
'Parent',grid2x2);

% (2,1)
% iterateToggle
thisTagStr = 'iterateToggle';
uiControlsHandles.iterateToggle = uicontrol(...
'Tag',[pluginObj.pluginFieldName '_panel_' thisTagStr],...
'Style','togglebutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Iterate',...
'UserData',pluginObj.userData,...
'Callback',@gvPlotWindowPlugin.iterateButtonCallback,...
'Parent',grid2x2);

% Change iterateToggle String
set(uiControlsHandles.iterateToggle, 'String', sprintf('( %s ) Iterate', char(9654))); %start char (arrow)

% (1,2)
% openLegendButton
thisTagStr = 'openLegendButton';
uiControlsHandles.openLegendButton = uicontrol(...
'Tag',[pluginObj.pluginFieldName '_panel_' thisTagStr],...
'Style','pushbutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Show Legend',...
'UserData',pluginObj.userData,...
'Callback',@gvPlotWindowPlugin.openLegendButtonCallback,...
'Parent',grid2x2);

% (2,2)
% Use Hbox for delay
delayHbox = uix.HBox('Parent',grid2x2, 'Spacing',spacing, 'Padding',padding);
makeDelayHbox(delayHbox);

% Set layout sizes
set(grid2x2, 'Heights',[-1 -1], 'Widths',[-1 -1]);

% Store Handles
% pluginObj.handles.plotPanel.controls = uiControlsHandles;


%% Nested fn
  function makeDelayHbox(delayHbox)
    % delayLabel
    thisTagStr = 'delayLabel';
    uiControlsHandles.delayLabel = uicontrol(...
      'Tag',[pluginObj.pluginFieldName '_panel_' thisTagStr],...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Delay [s]:',...
      'Parent',delayHbox);
    
    
    % delayValueBox
    thisTagStr = 'delayValueBox';
    uiControlsHandles.delayValueBox = uicontrol(...
      'Tag',[pluginObj.pluginFieldName '_panel_' thisTagStr],...
      'Style','edit',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','0.5',...
      'Value',0.5,...
      'UserData',pluginObj.userData,...
      'Callback',@gvPlotWindowPlugin.delayEditCallback,...
      'Parent',delayHbox);
    
      set(delayHbox, 'Widths',[-3, -1.3])
  end

end
