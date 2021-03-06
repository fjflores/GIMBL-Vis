%% gvImageWindowPlugin - Image Window Plugin Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis image window.

% Note:
%   imageRegexp can be regexp string or cellstring of 2-3 regexp. if string,
%   needs two groups. first group is imagetype, second group is sim id. if
%   cellstr, first cell is imagetype, second cell is sim id. if 3rd cell, this
%   is used as alternate name if the imagetype is matched as 'study', the
%   default dynasim prefix.

classdef gvImageWindowPlugin < gvWindowPlugin

  %% Public properties %%
  properties
    metadata = struct()
    
    handles = struct()
  end
  
  
  properties (Constant)
    pluginName = 'Image';
    pluginFieldName = 'image';
    
    windowName = 'Image Window';
  end
  
  
  %% Events %%
  events
    
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvImageWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrlObj)
      setup@gvWindowPlugin(pluginObj, cntrlObj);
      
      pluginObj.metadata.imageRegexp = pluginObj.controller.app.config.defaultImageRegexp;
      
      % image lists
      pluginObj.metadata.dirList = [];
      pluginObj.metadata.imageFileTypes = [];
      pluginObj.metadata.imageFileInd = [];
      
      pluginObj.metadata.matchedImageList = [];
      pluginObj.metadata.matchedImageIndList = [];
      
      pluginObj.addWindowOpenedListenerToPlotPlugin();
    end

    openWindow(pluginObj)
    
    panelHandle = makePanelControls(pluginObj, parentHandle)

  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    function status = makeFig(pluginObj)
      % makeFig - make image window figure
      
      if ~isValidFigHandle(pluginObj.controller.plugins.plot.handles.fig)
        wprintf('Plot Window must be open to open Image Window.');
        status = 1;
        return
      end
      
      plotPanPos = pluginObj.controller.plugins.plot.handles.fig.Position;
      newPos = plotPanPos; % same size as plot window
      newPos(1) = newPos(1)+newPos(3)+50; % move right
      %       newPos(3:4) = newPos(3:4)*.8; %shrink
      imageWindowHandle = figure(...
        'Name',['GIMBL-VIS: ' pluginObj.windowName],...
        'Tag',pluginObj.figTag(),...
        'NumberTitle','off',...
        'Position',newPos,...
        'color','white');
      
      makeBlankAxes(imageWindowHandle);
      
      % set image handle
      pluginObj.handles.fig = imageWindowHandle;
      
      status = 0;
    end
    
    
    function addWindowOpenedListenerToPlotPlugin(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        if isfield(pluginObj.metadata, 'plotWindowListener')
          delete(pluginObj.metadata.plotWindowListener)
        end
        
        pluginObj.metadata.plotWindowListener = addlistener(pluginObj.controller.windowPlugins.plot, 'windowOpened', @gvImageWindowPlugin.Callback_plotWindowOpened);
        
        pluginObj.vprintf('gvImageWindowPlugin: Added window opened listener to plot plugin.\n');
      end
    end
    
    
    function addMouseMoveCallbackToPlotFig(pluginObj)
      if isfield(pluginObj.controller.windowPlugins, 'plot')
        plotFigH = pluginObj.controller.windowPlugins.plot.handles.fig;
        set(plotFigH, 'WindowButtonMotionFcn', @gvImageWindowPlugin.Callback_mouseMove);
        
        pluginObj.vprintf('gvImageWindowPlugin: Added WindowButtonMotionFcn callback to plot plugin figure.\n');
      end
    end
    
    
    function pathStr = getImageDirPath(pluginObj)
      boxObj = findobjReTag('image_panel_imageDirBox');
      pathStr = boxObj.String;
      
      cwd = pluginObj.controller.app.workingDir;
      if isempty(pathStr) % if blank
        pathStr = cwd;
      elseif pathStr(1) == '.' % if rel path
        pathStr = fullfile(cwd, pathStr);
      end
    end

    
    function imageTypes = getImageTypes(pluginObj)
      imageDir = pluginObj.getImageDirPath;
      
      if isfolder(imageDir)
        if isempty(pluginObj.metadata.imageFileTypes)
          % usually called with makePanelControls
          pluginObj.updateAllImageList();
        end
        
        imageFileTypes = pluginObj.metadata.imageFileTypes;
        
        if isempty(imageFileTypes)
          imageTypes = '[ None ]';
        else
          imageTypes = unique(imageFileTypes);
        end
      else
        imageTypes = '[ None ]';
      end
    end
    
    
    function [imageTypes, imageInd] = useImageRegExp(pluginObj)
      % gets cellstr of image types and index for each file in imageDir
      
      imageDir = pluginObj.getImageDirPath;
      
      if isfolder(imageDir)
        % Find images in imageDir
        dirList = pluginObj.getAllImageList();
        
        imageRegExp = pluginObj.metadata.imageRegexp;
        
        if ischar(imageRegExp)
          % Parse image names
          imageFiles = regexp(dirList, imageRegExp, 'tokens');
          imageFiles = imageFiles(~cellfun(@isempty, imageFiles));
          imageFiles = cellfunu(@(x) x{1}, imageFiles);
          
          imageTypes = cellfunu(@(x) x{1}, imageFiles);
          imageInd = cellfunu(@(x) x{2}, imageFiles);
          imageInd = cellfun(@str2double, imageInd);
        else % iscell
          % Parse image names
          imageTypes = regexp(dirList, imageRegExp{1}, 'tokens');
          imageTypes = imageTypes(~cellfun(@isempty, imageTypes));
          imageTypes = cellfunu(@(x) x{1}, imageTypes);
          imageTypes = cellfunu(@(x) x{1}, imageTypes);
          
          % Parse image index
          imageInd = regexp(dirList, imageRegExp{2}, 'tokens');
          imageInd = imageInd(~cellfun(@isempty, imageInd));
          imageInd = cellfunu(@(x) x{1}, imageInd);
          imageInd = cellfunu(@(x) x{1}, imageInd);
          imageInd = cellfun(@str2double, imageInd);
          
          % alternate name if 3rd regexp cell
          if length(imageRegExp) > 2
            % find alt names
            altImageFiles = regexp(dirList, imageRegExp{3}, 'tokens');
            altImageFiles = altImageFiles(~cellfun(@isempty, altImageFiles));
            altImageFiles = cellfunu(@(x) x{1}, altImageFiles);
            altImageFiles = cellfunu(@(x) x{1}, altImageFiles);
            
            if ~isempty(altImageFiles)
              % find filenames mathcing study
              studyInds = strcmp(imageTypes, 'study');

              % replace name wiht alt name
              imageTypes(studyInds) = altImageFiles(studyInds);
            end
          end
        end
      else
        imageTypes = [];
        imageInd = [];
      end % if isfolder(imageDir)
    end
    
      
    function imageType = getImageTypeFromGUI(pluginObj)
      % get menu handle
      imgTypeMenu = findobjReTag('image_panel_imageTypeMenu');
      
      imageTypes = imgTypeMenu.String;
      
      imageType = imageTypes{imgTypeMenu.Value};
    end
    
    
    function dirList = getAllImageList(pluginObj, forceUpdateBool)
      if nargin < 2
        forceUpdateBool = false;
      end
      
      imageDir = pluginObj.getImageDirPath;
      
      if isempty(pluginObj.metadata.dirList) || forceUpdateBool
        removePathBool = true;
        dirList = lscell(imageDir, removePathBool);
        
        % store to metadata to speed up future calls
        pluginObj.metadata.dirList = dirList;
      else
        dirList = pluginObj.metadata.dirList;
      end
    end
    
    
    function updateImageTypeListControl(pluginObj)
      % get menu handle
      imgTypeMenu = findobjReTag('image_panel_imageTypeMenu');
      
      % update menu string with image types from dir
      imgTypeMenu.String = pluginObj.getImageTypes();
    end
    
    
    function updateAllImageList(pluginObj)
      % get list of all images
      forceUpdateBool = true;
      getAllImageList(pluginObj, forceUpdateBool);
      
      % use regexp
      [pluginObj.metadata.imageFileTypes, pluginObj.metadata.imageFileInd] = useImageRegExp(pluginObj);
    end
    
    
    function updateMatchedImageList(pluginObj)
      % get chosen menu str
      thisStr = pluginObj.getImageTypeFromGUI();
      
      % update matched list
      matches = contains(pluginObj.metadata.imageFileTypes, thisStr);
      pluginObj.metadata.matchedImageList = pluginObj.metadata.dirList(matches);
      pluginObj.metadata.matchedImageIndList = pluginObj.metadata.imageFileInd(matches);
    end
    
  end
  
  %% Static %%
  methods (Static, Hidden)
    
    function str = helpStr()
      str = [gvImageWindowPlugin.pluginName ':\n',...
        'Use the Select tab or mouse over a Plot window data point to choose an ',...
        'image to display.\n'
        ];
    end
    
    
    %% Callbacks %%
    function Callback_image_panel_openWindowButton(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      pluginObj.openWindow();
    end
    
    
    function Callback_image_panel_imageDirBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin

      pluginObj.updateAllImageList();
      
      pluginObj.updateImageTypeListControl();
      
      pluginObj.updateMatchedImageList();
    end
    
    
    function Callback_image_panel_imageTypeMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin

      pluginObj.updateMatchedImageList();
    end
    
    function Callback_plotWindowOpened(src, evnt)
      if isfield(src.controller.windowPlugins, 'image')
        pluginObj = src.controller.windowPlugins.image;

        pluginObj.addMouseMoveCallbackToPlotFig();
      end
    end
  
    
    function Callback_image_panel_imageRegexpBox(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      % update imageRegexp
      pluginObj.metadata.imageRegexp = shebangParse(src.String);
      
      pluginObj.updateImageTypeListControl();
      
      pluginObj.updateMatchedImageList();
    end
    
    Callback_mouseMove(src, evnt)
  end
  
end
