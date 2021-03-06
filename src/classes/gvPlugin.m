%% gvPlugin - Abstract Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              plugins

classdef (Abstract) gvPlugin < handle

  %% Abstract Properties %%
  properties (Abstract)
    metadata 
  end
  
  properties (Abstract, Constant)
    pluginName
    pluginFieldName
  end
  
  
  %% Concrete Properties %%
  properties
    pluginClassName
    
    pluginType = []
  end
  
  properties (SetAccess = protected)
    controller
  end
  
  
  %% Abstract Methods %%
  methods (Abstract)
  end
  
  %% Concrete Methods %%
  methods
    
    function pluginObj = gvPlugin(cntrlObj)
      pluginObj.pluginClassName = class(pluginObj);
      
      if nargin
        setup(pluginObj, cntrlObj);
      end
    end
    
    
    function setup(pluginObj, cntrlObj)
      pluginObj.addController(cntrlObj);
    end
    
    
    function vprintf(pluginObj, varargin)
      pluginObj.controller.app.vprintf(varargin{:});
    end
    
    
    function addController(pluginObj, cntrlObj)
      % uni add
      %
      % use connectToController for bi
      
      pluginObj.controller = cntrlObj;
    end
    
    
    function connectToController(pluginObj, cntrlObj)
      % See also: gvController/connectPlugin
      
      pluginObj.addController(cntrlObj);
      cntrlObj.addPlugin( pluginObj );
    end
    
    
    function removeController(pluginObj)
      % uni remove
      %
      % use disconnect for bi
      
      pluginObj.controller = [];
    end
    
    
    function disconnectFromController(pluginObj)
      % See also: gvController/disconnectPlugin
      
      pluginObj.controller.removePlugin( pluginObj.pluginFieldName );
      pluginObj.removeController();
    end
    
    
    function varargout = getHelp(pluginObj)
      str = pluginObj.helpStr();
      if ~nargout
        fprintf(['\n' str '\n'])
      else
        varargout{1} = str;
      end
    end
    
  end
  
  %% Abstract Static Methods %%
  methods (Abstract, Static, Hidden)
    helpStr() % should return help string if argout, else fprintf the help string
  end
  
end
