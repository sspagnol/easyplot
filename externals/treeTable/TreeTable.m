classdef TreeTable < handle
    %treeTable - create Java-based tree-table based on javax.swing.JTable and javax.swing.JTree
    %
    % Syntax:
    %    jtable = treeTable (pnContainer, headers, data, 'PropName',PropValue, ...)
    %
    % Input Parameters:
    %    pnContainer - optional handle to container uipanel or figure. If empty/unsupplied then current figure will be used
    %    headers     - optional cell array of column header strings. If unsupplied then = {'A','B','C'}
    %    data        - optional vector/matrix (either scalar or cell array) of data values
    %    'PropName',PropValue -
    %                  optional list of property pairs (e.g., 'iconFilenames',{'a.gif','b.jpg'},'columnTypes',{'char','logical'})
    %                  Note: All optional parameters of treeTable may be specified using PropName/PropValue pairs,
    %                        case-insensitive, in whichever order (see the bottom example below):
    %                        - 'Container'      => HG handle             (default=gcf)
    %                        - 'Headers'        => cell array of labels  (default={'A','B',...} based on data size)
    %                        - 'Data'           => 2D cell/numeric array (default=[])
    %                        - 'IconFilenames'  => filepath strings      (default={leafIcon,folderClosedIcon,folderOpenIcon})
    %                        - 'ColumnTypes'    => 'char'/'logical'/{}   (default={'char','char',...})
    %                              Note 1: {'a','b','c'} indicates a non-editable combo-box with the specified data items
    %                              Note 2: {'a','b','c', ''} indicates *editable* combo-box with the specified data items
    %                        - 'ColumnEditable' => array of true/false   (default=[true,true,...])
    %                        - 'Groupable'           => logical flag     (default=true; if false, display as non-groupable table)
    %                        - 'InteractiveGrouping' => logical flag     (default=false; if true, enables interactive grouping as in Outlook)
    %
    % Output parameters:
    %    jtable      - handle to Java tree-table object
    %
    % Examples:
    %    jtable = treeTable;  % show demo with default parameter values
    %
    %    jtable = treeTable(gcf, 'column name');
    %
    %    data = {1,'M11',true,true,false; 1,'M12',true,false,true; 1,'M13',false,true,true; 2,'M21',true,true,false; 2,'M22',false,true,false;};
    %    jtable = treeTable(figure,{'Group','Panel','Mask','Object','ID'},data);
    %    jtable = treeTable(figure,{'Group','Panel','Mask','Object','ID'},data,'ColumnTypes',{'','char','logical','logical','logical'});
    %
    %    data = {1,'M11',true,true,'Yes'; 1,'M12',true,false,'No'; 1,'M13',false,true,'No'; 2,'M21',true,true,'Yes'; 2,'M22',false,true,'Maybe';};
    %    jtable = treeTable(figure,{'Group','Panel','Mask','Object','ID'},data,'ColumnTypes',{'','char','logical','logical',{'No','Yes',''}});
    %
    % Usage:
    %    The table is sortable.
    %    The table automatically resizes to fill the pnContainer (you may modify this via the 'Position' property).
    %    The table automatically sets the columns' cell editor and renderer based on the supplied data. Logical values are
    %       given a checkbox, strings are left-aligned (numbers are right-aligned). You can always override the defaults.
    %    You can change column widths by dragging the column borders.
    %    You can exchange columns by simply dragging the column header right or left.
    %    For additional tips about how to set multiple aspects of the table, refer to:
    %       <a href="http://java.sun.com/docs/books/tutorial/uiswing/components/table.html">http://java.sun.com/docs/books/tutorial/uiswing/components/table.html</a>
    %
    % Bugs and suggestions:
    %    Please send to Yair Altman (altmany at gmail dot com)
    %
    % See also:
    %    uitable, uitree, java, javaclasspath
    %
    % Release history:
    %    1.0 2011-01-02: Initial version
    %    1.1 2011-01-04: Added leaf/node icons
    %    1.2 2013-06-21: Adaptations for R2013b & HG2, supported uiextras.Panel parent, enabled multi-column sorting, added groupable flag, supported numeric data
    %    1.3 2013-08-04: Initial version posted on File Exchange: http://www.mathworks.com/matlabcentral/fileexchange/index?term=authorid%3A27420
    %    1.4 2013-08-06: Added InteractiveGrouping option
    
    % License to use and modify this code is granted freely to all interested, as long as the original author is
    % referenced and attributed as such. The original author maintains the right to be solely associated with this work.
    
    % Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
    % $Revision: 1.4 $  $Date: 2013/08/06 14:31:16 $
    
    %% Internal properties
    
    %properties(GetAccess = protected, SetAccess = protected)
    properties
        hContainer % Main panel
        JTable % Java table % jtable
        JTableModel % Java table model % model
        groupTableModel
        JColumnModel
        JSelectionModel
        JScrollPane % Java scroll pane
        JEditor % alternate Java cell editor
        Container % HG container
        IsConstructed = false; %true when the constructor is complete (internal)
        CBEnabled = false; %callbacks enabled state (internal)
    end
    
    properties(Dependent = true, SetAccess = protected, GetAccess = protected)
        JColumn
    end
    
    properties (Hidden = true)
        Debug = false;
    end
    
    properties(Constant = true, GetAccess = protected)
        ValidResizeModes = {
            'off'
            'next'
            'subsequent'
            'last'
            'all'
            };
        ValidSelectionModes = {
            'single'
            'contiguous'
            'discontiguous'
            };
    end
    
    properties
        Headers
        Data
        IconFilenames
        ColumnTypes
        ColumnEditable
        ColumnGroupBy
        Groupable
        InteractiveGrouping
        DockingGroup
        Extra
        paramsStruct
        imagecolumns
        imagetooltipheight
        imagerescandelay
    end
    
    methods
        function obj = TreeTable(varargin)
            % Ensure that java swing is enabled...
            if ~usejava('swing')
                error('treeTable:NeedSwing','Java tables require Java Swing.');
            end
            import javax.swing.*
            
            % Process optional arguments
            paramsStruct = obj.processArgs(varargin{:});
            
            if isempty(paramsStruct)
                % Start with dummy data, just so that uitable can be initialized (or use supplied data, if available)
                paramsStruct = struct;
                selector = {'One','Two','Many'};
                paramsStruct.ColumnTypes = {'label','label','char','logical',selector,'double'};
                paramsStruct.ColumnGroupBy = {true, false, false, false, false, false};
                paramsStruct.Headers = {'ID','Label','Logical1','Logical2','Selector','Numeric'};  % 5 columns by default
                paramsStruct.Data = {1,'M11',true, false,'One', 1011;  ...
                    1,'M12',true, true, 'Two', 12;   ...
                    1,'M13',false,false,'Many',13.4; ...
                    2,'M21',true, false,'One', 21;  ...
                    2,'M22',true, true, 'Two', 22;   ...
                    3,'M31',true, true, 'Many',31;   ...
                    3,'M32',false,true, 'One', -32;  ...
                    3,'M33',false,false,'Two', 33; ...
                    3,'M34',true, true, 'Many',34;  ...
                    };
            end
            
            % Create the table
            obj.create(obj, paramsStruct);
            
            % Force drawing updates
            drawnow;
            
            % Indicate construction is complete
            obj.IsConstructed = true;
            obj.CBEnabled = true;
        end% constructor
        
        function delete(obj)
            %delete  Destructor.
            
            % Disable callbacks
            obj.CBEnabled = false;
            
            % Check if container is already being deleted
            if strcmp(get(obj.Container, 'BeingDeleted'), 'off')
                delete(obj.Container)
            end
            
            % Remove references to the java objects
            obj.JTable = [];
            obj.JTableModel = [];
            obj.groupTableModel = [];
            obj.JColumnModel = [];
            obj.JSelectionModel = [];
            obj.JScrollPane = [];
            drawnow() % force repaint
        end % destructor
        
    end % structors
    
    methods(Access = protected, Static = true)
        
        %%
        function create(obj, paramsStruct)
            vnames = fieldnames(paramsStruct);
            for i = 1:length(vnames)
                thevar = char(vnames{i});
                obj.(thevar) = paramsStruct.(thevar);
            end
            
            if isa(handle(obj.Container), 'figure')
                pnContainerPos = getpixelposition(obj.Container,0);  % Fix for Matlab 7.0.4 as per Sebastian Hölz
                pnContainerPos(1:2) = 0;
            else
                try
                    pnContainerPos = getpixelposition(obj.Container,1);  % Fix for Matlab 7.0.4 as per Sebastian Hölz
                catch
                    pnContainerPos = getpixelposition(obj.Container);  % Fix for uiextras.Panel
                end
            end
            
            % Get handle to parent figure
            hFig = ancestor(obj.Container,'figure');
            
            % Get the uitable's required position within the container
            margins = [1,1,0,0];
            tablePosition = pnContainerPos + margins;    % Relative to the figure
            
            % Create a sortable uitable within the container
            try
                % Use JideTable if available on this system
                com.mathworks.mwswing.MJUtilities.initJIDE;
                
                % Prepare the tree-table with the requested data & headers
                %model = javax.swing.table.DefaultTableModel(paramsStruct.Data, paramsStruct.Headers);
                try
                    %model = MultiClassTableModel(obj.paramsStruct.Data, obj.paramsStruct.Headers);  %(model)
                    model = MultiClassTableModel(obj.Data, obj.Headers);  %(model)
                catch
                    try
                        javaaddpath(fileparts(mfilename('fullpath')));
                        model = MultiClassTableModel(obj.Data, obj.Headers);  %(model)
                    catch
                        % Revert to the default table model
                        % (which has problematic numeric sorting since it does not recognize numeric data columns)
                        err = lasterror;
                        model = javax.swing.table.DefaultTableModel(obj.Data, obj.Headers);
                    end
                end
                obj.JTable = eval('com.jidesoft.grid.GroupTable(model);');  % prevent JIDE alert by run-time (not load-time) evaluation
                obj.JTable = handle(javaObjectEDT(obj.JTable), 'CallbackProperties');
                obj.JTable.setRowAutoResizes(true);
                obj.JTable.setColumnAutoResizable(true);
                obj.JTable.setColumnResizable(true);
                obj.JTable.setShowGrid(false);
                
                % Wrap the standard model in a JIDE GroupTableModel
                %model = JTable.getModel;
                obj.groupTableModel = com.jidesoft.grid.DefaultGroupTableModel(model);
                %model = StyledGroupTableModel(JTable.getModel);
                
                % Automatically group by the first column (only if it has multiple value)
                if obj.Groupable
                    % always group on java column 0
                    obj.ColumnGroupBy{1} = true;
                    for colIdx = 0 : length(obj.ColumnTypes)-1
                        if obj.ColumnGroupBy{colIdx+1}
                            obj.groupTableModel.addGroupColumn(colIdx);
                        end
                    end
                    obj.groupTableModel.groupAndRefresh;
                    % collapse empty column types
                    obj.ColumnTypes([obj.ColumnGroupBy{:}])=[];
                end
                obj.JTable.setModel(obj.groupTableModel);
                
                % Enable multi-column sorting
                obj.JTable.setSortable(true);
                
                % Automatically resize all columns - this can be extremely SLOW for >1K rows!
                %jideTableUtils = eval('com.jidesoft.grid.TableUtils;');  % prevent JIDE alert by run-time (not load-time) evaluation
                %jideTableUtils.autoResizeAllColumns(JTable);
                
                obj.refreshColumnRenderersEditors(obj);
                obj.JTable.setSelectionBackground(java.awt.Color(0.9608*.8,0.9608*.8, 0.9608));  % light-blue
                
                % Modify the group style (doesn't work on new Matlab releases)
                %{
          try
              iconPath = paramsStruct.IconFilenames{2};
              groupStyle = model.getGroupStyle;
              groupStyle.setBackground(java.awt.Color(.7,.7,.7));  % light-gray
              if ~isempty(iconPath)
                  icon = javax.swing.ImageIcon(iconPath);
                  groupStyle.setIcon(icon);
              end
          catch
              %fprintf(2, 'Invalid group icon: %s (%s)\n', char(iconPath), lasterr);
              a=1;   % never mind - probably an invalid icon
          end
                %}
                try
                    obj.JTable.setExpandedIcon (javax.swing.ImageIcon(obj.IconFilenames{2}));
                    obj.JTable.setCollapsedIcon(javax.swing.ImageIcon(obj.IconFilenames{3}));
                catch
                    %fprintf(2, 'Invalid group icon: %s (%s)\n', char(iconPath), lasterr);
                    a=1;   % never mind - probably an invalid icon
                end
                
                % Attach a GroupTableHeader so that we can use Outlook-style interactive grouping
                try
                    jTableHeader = com.jidesoft.grid.GroupTableHeader(obj.JTable);
                    obj.JTable.setTableHeader(jTableHeader);
                    if obj.InteractiveGrouping
                        jTableHeader.setGroupHeaderEnabled(true);
                    end
                catch
                    warning('YMA:treeTable:InteractiveGrouping','InteractiveGrouping is not supported - try using a newer Matlab release');
                end
                
                % Present the tree-table within a scrollable viewport on-screen
                scroll = javaObjectEDT(javax.swing.JScrollPane(obj.JTable));
                hParent = obj.Container;
                try
                    % HG2 sometimes needs double(), sometimes not, so try both of them...
                    [obj.JScrollPane, obj.hContainer] = javacomponent(scroll, tablePosition, double(hParent));
                catch
                    [obj.JScrollPane, obj.hContainer] = javacomponent(scroll, tablePosition, hParent);
                end
                set(obj.hContainer,'units','normalized','pos',[0,0,1,1]);  % this will resize the table whenever its container is resized
                pause(0.05);
            catch
                err = lasterror;
                obj.hContainer = [];
            end
            
            % Fix for JTable focus bug : see http://bugs.sun.com/bugdatabase/view_bug.do;:WuuT?bug_id=4709394
            % Taken from: http://xtargets.com/snippets/posts/show/37
            obj.JTable.putClientProperty('terminateEditOnFocusLost', java.lang.Boolean.TRUE);
            
            % Enable multiple row selection, auto-column resize, and auto-scrollbars
            %scroll = mtable.TableScrollPane;
            scroll.setVerticalScrollBarPolicy(scroll.VERTICAL_SCROLLBAR_AS_NEEDED);
            scroll.setHorizontalScrollBarPolicy(scroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
            obj.JTable.setSelectionMode(javax.swing.ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
            
            % Comment the following line in order to prevent column resize-to-fit
            obj.JTable.setAutoResizeMode(obj.JTable.java.AUTO_RESIZE_SUBSEQUENT_COLUMNS)
            %JTable.setAutoResizeMode(JTable.java.AUTO_RESIZE_OFF)
            
            % Set the JTable name based on the containing panel's tag
            try
                basicTagName = get(obj.Container,'tag');
                obj.JTable.setName([basicTagName 'Table']);
            catch
                % never mind...
            end
            
            % Move the selection to first table cell (if any data available)
            if (obj.JTable.getRowCount > 0)
                obj.JTable.changeSelection(0,0,false,false);
            end
            
            % Set default editing & selection callbacks
            try
                oldWarnState = warning('off','MATLAB:hg:JavaSetHGProperty');
                %set(handle(getOriginalModel(JTable),'CallbackProperties'), 'TableChangedCallback', {@tableChangedCallback, JTable});
                %set(handle(JTable.getSelectionModel,'CallbackProperties'), 'ValueChangedCallback', {@selectionCallback,    JTable});
                warning(oldWarnState);
            catch
                a=1;  % never mind...
            end
            
            % Process optional args
            obj.processParams(obj);
            
            % Fix for deployed app - show docking control
            set(hFig,'DockControls','on');
            %catch
            % Insert your code here
            %handleError;
            %end
            
        end
    end
    
    methods(Access = protected, Static = true)
        %% Set the column renderers/editors
        function refreshColumnRenderersEditors(obj)
            
            import javax.swing.*
            for colIdx = 0 : length(obj.ColumnTypes)-1
                % Set the column's cellRenderer and editor based on the declared ColumnTypes
                try
                    colType = obj.ColumnTypes{colIdx+1};
                    cellRenderer = obj.getDefaultCellRenderer();  % default cellRenderer = label
                    
                    % Cell array => combo-box
                    if iscellstr(colType)
                        % Combo-box editor (no need for a special renderer - use default label)
                        emptyIdx = cellfun('isempty',colType);
                        colType(emptyIdx) = [];
                        editableFlag = any(emptyIdx);
                        cb = JComboBox(colType);
                        cb.setEditable(editableFlag);
                        cbe = DefaultCellEditor(cb);
                        try
                            % If non-editable, disable combo-box
                            if ~obj.ColumnEditable{colIdx+1}
                                cbe.setClickCountToStart(1e6);
                            end
                        catch
                        end
                        obj.JTable.getColumnModel.getColumn(colIdx).setCellEditor(cbe);
                        obj.JTable.getColumnModel.getColumn(colIdx).setCellRenderer(cellRenderer);
                        
                        % 'logical' => checkbox
                    elseif strcmpi(colType,'logical')
                        % Checkbox editor
                        cbe = DefaultCellEditor(JCheckBox);
                        cbe.getComponent.setHorizontalAlignment(SwingConstants.CENTER);
                        try
                            % If non-editable, disable checkbox
                            if ~obj.ColumnEditable{colIdx+1}
                                cbe.setClickCountToStart(1e6);
                            end
                        catch
                        end
                        obj.JTable.getColumnModel.getColumn(colIdx).setCellEditor(cbe);
                        
                        % Checkbox renderer
                        cellRenderer = javaObject('javax.swing.JTable$BooleanRenderer');
                        cellRenderer.setHorizontalAlignment(SwingConstants.CENTER);
                        obj.JTable.getColumnModel.getColumn(colIdx).setCellRenderer(cellRenderer);
                        
                        % 'label' or 'char' => label
                    elseif strcmpi(colType,'label') || strcmpi(colType,'char')
                        try
                            % If non-editable, disable checkbox
                            if ~obj.ColumnEditable{colIdx+1}
                                jtf = javax.swing.JTextField;
                                jtf.setEditable(false);
                                jte = DefaultCellEditor(jtf);
                                jte.setClickCountToStart(intmax);
                                obj.JTable.getColumnModel.getColumn(colIdx).setCellEditor(jte);
                            end
                        catch
                        end
                        obj.JTable.getColumnModel.getColumn(colIdx).setCellRenderer(cellRenderer);
                        
                        %else
                        % never mind - leave as-is (label)
                    end
                catch
                    err = lasterror;  % never mind
                    a=1;
                end
                %return;
                
                % The first column should have an icon
                if colIdx == 0 && obj.Groupable
                    try
                        iconPath = obj.IconFilenames{1};
                        if ~isempty(iconPath)
                            icon = javax.swing.ImageIcon(iconPath);
                            cellRenderer.setIcon(icon);
                        end
                    catch
                        fprintf(2, 'Invalid leaf icon: %s (%s)\n', char(iconPath), lasterr);
                        a=1;   % never mind - probably an invalid icon
                    end
                end
            end
        end  % refreshColumnRenderersEditors
        
        
        %% Get the basic JTable data model
        function originalModel = getOriginalModel(JTable)
            originalModel = JTable.getModel;
            try
                while(true)
                    originalModel = originalModel.getActualModel;
                end;
            catch
                a=1;  % never mind - bail out...
            end
        end  % getOriginalModel
        
        %% Process optional arguments
        function paramsStruct = processArgs(varargin)
            
            % Fix edge-case
            if nargin>=2 && ischar(varargin{2})
                varargin{2} = {varargin{2}};
            end
            
            % Get the properties in either direct or P-V format
            [regParams, pvPairs] = parseparams(varargin);
            
            % Now process the optional P-V params
            try
                % Initialize
                paramName = '';
                paramsStruct = struct;
                paramsStruct.Container = gobjects(0);
                paramsStruct.Headers = {' '};  % 5 columns by default
                paramsStruct.Data = {};
                paramsStruct.IconFilenames = {fullfile(matlabroot,'/toolbox/matlab/icons/greenarrowicon.gif'), ...
                    fullfile(matlabroot,'/toolbox/matlab/icons/file_open.png'), ...
                    fullfile(matlabroot,'/toolbox/matlab/icons/foldericon.gif'), ...
                    };
                paramsStruct.ColumnTypes = {}; %{'label','logical',{'True','False',''},{'Yes','No'}};
                paramsStruct.ColumnEditable = {true, true, true, true, true};
                paramsStruct.ColumnGroupBy = {true, false, false, false, false};
                paramsStruct.DockingGroup = 'Figures';
                paramsStruct.Extra = {};
                paramsStruct.Groupable = true;
                paramsStruct.InteractiveGrouping = false;
                
                % Parse the regular (non-named) params in recption order
                if length(regParams)>0,  paramsStruct.Container = regParams{1};  end  %#ok
                if length(regParams)>1,  paramsStruct.Headers   = regParams{2};  end
                if length(regParams)>2,  paramsStruct.Data      = regParams{3};  end
                
                % Parse the optional param PV pairs
                supportedArgs = fieldnames(paramsStruct);  % ={'container', 'headers', 'data', 'iconfilenames', 'columntypes', 'columneditable', 'dockinggroup'};
                while ~isempty(pvPairs)
                    
                    % Ensure basic format is valid
                    paramName = '';
                    if ~ischar(pvPairs{1})
                        error('YMA:treeTable:invalidProperty','Invalid property passed to treeTable');
                    elseif length(pvPairs) == 1
                        error('YMA:treeTable:noPropertyValue',['No value specified for property ''' pvPairs{1} '''']);
                    end
                    
                    % Process parameter values
                    paramName  = pvPairs{1};
                    paramValue = pvPairs{2};
                    pvPairs(1:2) = [];
                    if any(strncmpi(paramName,supportedArgs,length(paramName)))
                        paramsStruct.(paramName) = paramValue; %paramsStruct.(lower(paramName)) = paramValue;
                    else
                        paramsStruct.Extra = {paramsStruct.Extra{:} paramName paramValue};
                    end
                end  % loop pvPairs
                
                % Create a panel spanning entire figure area, if container handle was not supplied
                if isempty(paramsStruct.Container) || (~ishandle(paramsStruct.Container) && ~isa(paramsStruct.Container,'uiextras.Panel'))
                    paramsStruct.Container = uipanel('parent',gcf,'tag','TablePanel');
                end
                
                % Set default header names, if not supplied
                if isempty(paramsStruct.Headers)
                    if isempty(paramsStruct.Data)
                        paramsStruct.Headers = {' '};
                    else
                        paramsStruct.Headers = cellstr(char('A'-1+(1:size(paramsStruct.Data,2))'))';
                    end
                elseif ischar(paramsStruct.Headers)
                    paramsStruct.Headers = {paramsStruct.Headers};
                end
                
                % Convert data to cell-format (if not so already)
                paramsStruct.Data           = TreeTable.cellizeData(paramsStruct.Data);
                paramsStruct.Headers        = TreeTable.cellizeData(paramsStruct.Headers);
                paramsStruct.ColumnTypes    = TreeTable.cellizeData(paramsStruct.ColumnTypes);
                paramsStruct.ColumnEditable = TreeTable.cellizeData(paramsStruct.ColumnEditable);
                paramsStruct.ColumnGroupBy  = TreeTable.cellizeData(paramsStruct.ColumnGroupBy);
                
                % Ensure we have valid column types & editable flags for all columns
                numCols = size(paramsStruct.Data,2);
                [paramsStruct.Headers{end+1:numCols}]        = deal(' ');
                [paramsStruct.ColumnTypes{end+1:numCols}]    = deal('char');
                [paramsStruct.ColumnEditable{end+1:numCols}] = deal(true);
                [paramsStruct.ColumnGroupBy{end+1:numCols}] = deal(false);
                
                % TBD - Ensure icon filenames are readable and in the correct format
                a=1;
            catch
                if ~isempty(paramName),  paramName = [' ''' paramName ''''];  end
                err = lasterror;
                error('YMA:treeTable:invalidProperty',['Error setting treeTable property' paramName ':' char(10) lasterr]);
            end
            
        end  % processArgs
        
        %% Convert a numeric matrix to a cell array (if not so already)
        function data = cellizeData(data)
            if ~iscell(data)
                %data = mat2cell(data,ones(1,size(data,1)),ones(1,size(data,2)));
                data = num2cell(data);
            end
        end  % cellizeData
        
        %% Process optional arguments on the newly-created table object
        function processParams(obj)
            try
                % Process regular extra parameters
                paramName = '';
                th = obj.JTable.getTableHeader;
                %container = get(mtable,'uicontainer');
                drawnow; pause(0.05);
                for argIdx = 1 : 2 : length(obj.Extra)
                    if argIdx<2
                        % We need this pause to let java complete all table rendering
                        % TODO: We should really use calls to awtinvoke() instead, though...
                        pause(0.05);
                    end
                    if (length(obj.Extra) > argIdx)   % ensure the arg value is there...
                        obj.Extra{argIdx}(1) = upper(obj.Extra{argIdx}(1));  % property names always start with capital letters...
                        paramName  = obj.Extra{argIdx};
                        paramValue = obj.Extra{argIdx+1};
                        propMethodName = ['set' paramName];
                        
                        % First try to modify the container
                        try
                            set(obj.Container, paramName, paramValue);
                        catch
                            try % if ismethod(mtable,propMethodName)
                                % No good, so try the mtable...
                                set(mtable, paramName, paramValue);
                            catch %elseif ismethod(JTable,propMethodName)
                                try
                                    % sometimes set(t,x,y) failes but t.setX(y) is ok...
                                    javaMethod(propMethodName, mtable, paramValue);
                                catch
                                    try
                                        % Try to modify the underlying JTable itself
                                        set(obj.JTable, paramName, paramValue);
                                    catch
                                        try
                                            javaMethod(propMethodName, obj.JTable, paramValue);
                                        catch
                                            try
                                                % Try to modify the table header...
                                                set(th, paramName, paramValue);
                                            catch
                                                javaMethod(propMethodName, th, paramValue);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end  % for argIdx
                drawnow; pause(0.05);
                
                % Process requested image columns
                try
                    if ~isempty(which('ImageCellRenderer')) && ~isempty(obj.IconFilenames)
                        %TODO TBD
                        cr = ImageCellRenderer(obj.imagetooltipheight, obj.imagerescandelay*1000);
                        if ischar(obj.IconFilenames)
                            % Maybe a header name?
                            JTable.getColumn(obj.imagecolumns).setCellRenderer(cr);
                        elseif iscellstr(obj.imagecolumns)
                            % Cell array of header names
                            for argIdx = 1 : length(obj.imagecolumns)
                                JTable.getColumn(obj.imagecolumns{argIdx}).setCellRenderer(cr);
                                drawnow;
                            end
                        else
                            % Try to treat as a numeric index array
                            for argIdx = 1 : length(obj.imagecolumns)
                                colIdx = obj.imagecolumns(argIdx) - 1;  % assume 1-based indexing
                                %JTable.setEditable(colIdx,0);  % images are editable!!!
                                JTable.getColumnModel.getColumn(colIdx).setCellRenderer(cr);
                                drawnow;
                            end
                        end
                        drawnow;
                    elseif ~isempty(obj.imagecolumns)  % i.e., missing Renderer
                        warning('YMA:treeTable:missingJavaClass','Cannot set image columns: ImageCellRenderer.class is missing from the Java class path');
                    end
                    obj.JTable.repaint;
                catch
                end
                
                % Process UIContextMenu
                cm = get(obj.Container,'uicontextmenu');
                if ~isempty(cm)
                    popupMenu = obj.JTable.getRowHeaderPopupMenu;
                    %popupMenu.list;
                    popupMenu.removeAll; drawnow; pause(0.1);
                    cmChildren = get(cm,'child');
                    itemNum = 0;
                    for cmChildIdx = length(cmChildren) : -1 : 1
                        %{
                if itemNum == 6
                    % add 2 hidden separators which will be removed by the Matlab mouse listener...
                    popupMenu.addSeparator;
                    popupMenu.addSeparator;
                    popupMenu.getComponent(5).setVisible(0);
                    popupMenu.getComponent(6).setVisible(0);
                    itemNum = 8;
                end
                % Add a possible separator
                if strcmpi(get(cmChildren(cmChildIdx),'Separator'),'on')
                    popupMenu.addSeparator;
                    itemNum = itemNum + 1;
                end
                if itemNum == 6
                    % add 2 hidden separators which will be removed by the Matlab mouse listener...
                    popupMenu.addSeparator;
                    popupMenu.addSeparator;
                    popupMenu.getComponent(5).setVisible(0);
                    popupMenu.getComponent(6).setVisible(0);
                    itemNum = 8;
                end
                        %}
                        % Ramiro's fix:
                        % "Though your code supports it, right now it has a little bug that if the user
                        %  has more than 6 entries in the context menu, only 1 separator is shown at a
                        %  fixed position. I was able to go around this problem using this code:"
                        if itemNum==1 || itemNum==2 || itemNum==8 || itemNum==9
                            popupMenu.addSeparator;
                        end
                        % End Ramiro's fix
                        
                        % Add the main menu item
                        jMenuItem = javax.swing.JMenuItem(get(cmChildren(cmChildIdx),'Label'));
                        set(jMenuItem,'ActionPerformedCallback',get(cmChildren(cmChildIdx),'Callback'));
                        popupMenu.add(jMenuItem);
                        itemNum = itemNum + 1;
                    end
                    for extraIdx = itemNum+1 : 7
                        popupMenu.addSeparator;
                        popupMenu.getComponent(extraIdx-1).setVisible(0);
                    end
                    drawnow;
                end
                
                % Process docking group
                drawnow; pause(0.05);
                group = obj.DockingGroup;
                if ~strcmp(group,'Figures')
                    try
                        jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
                        currentGroupNames = cell(jDesktop.getGroupTitles);
                        if ~any(strcmp(group,currentGroupNames))
                            jDesktop.addGroup(group);
                        end
                        
                        % Temporarily dock first figure into the group, to ensure container creation
                        % Note side effect: group container becomes visible
                        hFig = ancestor(obj.Container,'figure');
                        try
                            jFrame = get(mtable,'ParentFigureValidator');
                        catch
                            % old Matlab versions used a different property name
                            jFrame = get(mtable,'UserParentFigure');
                        end
                        set(jFrame,'GroupName',group);
                        %oldStyle = get(hFig,'WindowStyle');
                        %set(hFig,'WindowStyle','docked');  drawnow
                        %set(hFig,'WindowStyle',oldStyle);  drawnow
                        %commandwindow;
                        drawnow; pause(0.02);
                        try
                            jDesktop.setGroupDocked(group,false);
                            jDesktop.showGroup(group,true);
                        catch
                            % never mind...
                        end
                        figure(hFig);
                    catch
                        warning('YMA:treeTable:Docking',['Cannot dock figure: ' lasterr]);
                    end
                end
            catch
                if ~isempty(paramName),  paramName = [' ''' paramName ''''];  end
                err = lasterror;
                error('YMA:treeTable:invalidProperty',['Error setting treeTable property' paramName ' (line #' num2str(err.stack(1).line) '):' char(10) lasterr]);
            end
        end  % processParams
        
        %% Get the default cell renderer object
        function cr = getDefaultCellRenderer()
            try
                % Custom cell renderer (striping, cell FG/BG color, cell tooltip)
                cr = CustomizableCellRenderer;
                cr.setRowStriping(false);
            catch
                % Use the standard JTable cell renderer
                %cr = [];
                cr = javax.swing.table.DefaultTableCellRenderer;
            end
        end  % getDefaultCellRenderer
    end
    
    methods
        function redraw(obj)
            %redraw  Redraw table.
            %
            %  t.redraw() requests a redraw of the table t.
            
            jScrollPane = obj.JScrollPane;
            jScrollPane.repaint(jScrollPane.getBounds())
            
        end % redraws

        %% Sample set data
        function setTableData(obj, value)
%             [data,headers] = getTableData(bojJTable);
%             data = [data; newData];
%             setTableData(JTable,data,headers);

            obj.CBEnabled = false;
            obj.JTableModel = javax.swing.table.DefaultTableModel(value,obj.Headers);
            obj.groupTableModel = com.jidesoft.grid.DefaultGroupTableModel(obj.JTableModel);
            if obj.Groupable
                % always group on java column 0
                obj.ColumnGroupBy{1} = true;
                for colIdx = 0 : length(obj.ColumnTypes)-1
                    if obj.ColumnGroupBy{colIdx+1}
                        obj.groupTableModel.addGroupColumn(colIdx);
                    end
                end
                obj.groupTableModel.groupAndRefresh;
                % collapse empty column types
                %obj.ColumnTypes([obj.ColumnGroupBy{:}])=[];
            end
            obj.JTable.setModel(obj.groupTableModel);
            
            obj.refreshColumnRenderersEditors(obj);
            
            obj.JTable.repaint;
            obj.CBEnabled = true;
            obj.redraw();
        end  % addRow
        
        % CBEnabled
        function setCBEnabled(obj,value)
            drawnow;
            if isvalid(obj)
                obj.CBEnabled = value;
            end
            drawnow;
        end
        
        %% Sample row insertion function
        function addRow(JTable,newData)
            [data,headers] = getTableData(JTable);
            data = [data; newData];
            setTableData(JTable,data,headers);
        end  % addRow
        
        %% Sample row deletion function
        function deleteRow(JTable,rowIdx)
            JTable.getModel.removeRow(rowIdx);
            JTable.repaint;
        end  % addRow
        
        %% Sample table-editing callback
        function tableChangedCallback(hModel,hEvent,JTable)
            % Get the modification data
            modifiedRow = get(hEvent,'FirstRow');
            modifiedCol = get(hEvent,'Column');
            label   = hModel.getValueAt(modifiedRow,1);
            newData = hModel.getValueAt(modifiedRow,modifiedCol);
            
            % Now do something useful with this info
            fprintf('Modified cell %d,%d (%s) to: %s\n', modifiedRow+1, modifiedCol+1, char(label), num2str(newData));
        end  % tableChangedCallback
        
        %% Sample table-selection callback
        function selectionCallback(hSelectionModel,hEvent,JTable)
            % Get the selection data
            MinSelectionIndex  = get(hSelectionModel,'MinSelectionIndex');
            MaxSelectionIndex  = get(hSelectionModel,'MaxSelectionIndex');
            LeadSelectionIndex = get(hSelectionModel,'LeadSelectionIndex');
            
            % Now do something useful with this info
            fprintf('Selected rows #%d-%d\n', MinSelectionIndex+1, MaxSelectionIndex+1);
        end  % selectionCallback
        
    end
end