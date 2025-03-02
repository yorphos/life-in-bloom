# Life in Bloom - UI Architecture

## Overview

The Life in Bloom UI system uses a layered, modular architecture designed for:
- Consistency across all game interfaces
- Code reusability through component-based design
- Clear separation of concerns
- Maintainability and extensibility

## Layer Structure

The UI system is organized into distinct layers:

### 1. Foundation Layer

#### BaseUI Module

`BaseUI.luau` provides fundamental UI utilities and styling:

- **Color definitions**: Consistent color palette throughout the application
- **Basic UI element creation**: Functions to create frames, buttons, labels with consistent styling
- **UI reference management**: Centralized tracking of UI elements through a structured repository pattern
- **Common visual effects**: Shadows, gradients, transitions
- **Layout utilities**: Grid layouts, padding, and positioning helpers
- **Tab system**: Standardized tab creation and management
- **Card styling**: Common card formatting and hover effects
- **Visual indicators**: Badges, section headers, and other UI elements

**Core Utility Functions:**
- `CreateStyledButton`: Creates buttons with consistent styling and hover effects
- `CreateFrame`: Creates frames with standard styling
- `CreateLabel`: Creates text labels with consistent formatting
- `CreateSectionHeader`: Creates standardized section headers
- `CreateGridLayout`: Creates grid layouts with standard configuration
- `CreateTabSystem`: Creates a complete tab system with content switching
- `CreateBadge`: Creates badge indicators for quantities or notifications
- `ApplyCardStyle`: Applies standard card styling to a frame
- `ApplyHoverEffect`: Adds hover state animations to UI elements
- `ApplyPadding`: Applies consistent padding to UI elements
- `ApplyShadow`: Adds shadow effects to UI elements

**UI Reference Management System:**

The BaseUI module now includes a comprehensive UI reference management system that allows for:
- Centralized storage of UI references in a structured repository
- Organized categorization of references (core, modals, screens, components)
- Hierarchical access using dot notation paths
- Proper cleanup of references when UI elements are destroyed

**Reference Management Functions:**
- `AddRef(category, path, ref)`: Adds a UI reference to the specified category and path
- `GetRef(category, path)`: Retrieves a UI reference by category and path
- `UpdateRef(category, path, ref)`: Updates an existing UI reference
- `RemoveRef(category, path)`: Removes a UI reference from the repository
- `GetRefs(category, basePath)`: Gets all references in a category or path
- `ListenForRefChanges(callback)`: Sets up a listener for UI reference changes

**Usage Guidelines for References:**
- Always use dot notation for paths (e.g., "inventory.itemGrid")
- Store references when creating UI elements
- Clean up references when elements are destroyed
- Prefer GetRef over direct object references for better modularity
- Use consistent naming conventions for paths
- Always handle nil returns from GetRef for robustness

**Example of Reference System Usage:**

```lua
-- Adding a reference
local modal = CreateSomeModal()
BaseUI.AddRef("modals", "myModal.container", modal)

-- Getting a reference
local modalContainer = BaseUI.GetRef("modals", "myModal.container")
if modalContainer then
    -- Use the reference safely
end

-- Listening for reference changes
local disconnect = BaseUI.ListenForRefChanges(function(category, path, ref)
    print("Reference changed:", category, path)
end)

-- Cleaning up references
BaseUI.RemoveRef("modals", "myModal")
```

**Usage Guidelines:**
- Use these utilities to maintain UI consistency across all screens and modals
- Prefer these utilities over creating UI elements from scratch
- For complex components, use CoreComponents instead

### 2. Component Layer

#### CoreComponents Module

`CoreComponents.luau` builds reusable, higher-level components:

- **StatDisplay**: Shows player stats with icons and values
- **ProgressBar**: Visual representation of progress with animated fills
- **Notification**: System for displaying temporary messages
- **ItemCard**: Interactive display for inventory items

**Usage Guidelines:**
- Components should be composable and self-contained
- Each component should manage its own state and animations
- Expose simple interfaces through parameters

### 3. Modal System

#### ModalBase Module

`ModalBase.luau` provides the foundation for all dialog windows:

- **Standard modal behavior**: Opening/closing animations, backdrop, close button
- **Content management**: Scrollable content area with dynamic sizing
- **Z-index handling**: Proper layering of multiple modals
- **Modal tracking**: System to manage active modals

#### Specialized Modals

Built on top of ModalBase:
- **CareerModal**: Career progression and job management
- **HousingModal**: Property browsing and management 
- **SettingsModal**: Game configuration options

**Usage Guidelines:**
- Use ModalBase for all new dialog windows
- Implement a consistent tab system for complex modals
- Always connect data listeners for real-time updates

### 4. Screen Layer

#### Screen Modules

Full-screen UI layouts:
- **MainScreen**: Primary game interface with toolbar and status displays
- Future screens: Intro, Character Creation, etc.

**Usage Guidelines:**
- Screen modules should handle layout but delegate to components
- Maintain responsive design principles
- Keep screens as thin as possible, with logic in controllers

### 5. Controller Layer

#### UI Controllers

Manage the flow between data and UI:
- **MainUIController**: Coordinates all UI components and handles initialization
- **Other specialized controllers**: Handle specific UI subsystems

**Usage Guidelines:**
- Controllers should initialize UI components
- Connect data sources to UI elements
- Handle user interactions and state changes

## Data Flow

1. Player actions trigger UI events
2. UI Controllers process events and communicate with game systems
3. Data changes are propagated back to UI elements
4. PlayerDataController provides real-time updates to UI

### Access Patterns for Different Data Types

UI components should follow specific patterns when accessing different types of data:

#### Player Data

UI components should never access player data directly. Instead:

1. Request data through PlayerDataController
2. Register listeners for data changes
3. Update UI when data changes are detected

```lua
-- Example: Accessing player data
local playerMoney = PlayerDataController.GetDataByPath("Progression.Currency")

-- Example: Listening for changes
local disconnect = PlayerDataController.ListenForData("Progression.Currency", function(newValue)
    -- Update UI with new value
    currencyDisplay.Text = tostring(newValue)
end)

-- Clean up when no longer needed
disconnect()
```

#### Game Data (Static)

For static game data (careers, items, vehicles, etc.):

1. Request data through GameDataController
2. Cache results when appropriate
3. Handle loading states gracefully

```lua
-- Example: Accessing game data
local allCareers = GameDataController:GetAllCareers()

-- Example: Getting specific data
local chefCareer = GameDataController:GetCareerById("Chef")

-- Example: Checking requirements
local canSelectCareer = GameDataController:CanSelectCareer(playerId, "Chef")
```

#### Real-time Game State

For dynamic game state that changes frequently:

1. Use dedicated controllers for specific systems
2. Implement appropriate update mechanisms (polling vs. events)
3. Consider performance implications for high-frequency updates

## Best Practices

1. **Component Composition**: Build complex UIs from simple components
2. **Clean Event Handling**: 
   - Use explicit connections with proper cleanup
   - Store connections in tables and disconnect them when no longer needed
   - Avoid memory leaks by properly managing event connections
3. **UI Reference Management**:
   - Always use the BaseUI reference system for storing and retrieving UI elements
   - Organize references with logical path structures for clarity
   - Use category names that match the UI's purpose (modals, screens, components, etc.)
   - Clean up references when UI elements are destroyed
   - Always check for nil when getting references to avoid errors
   - Use consistent naming conventions for paths to maintain clarity
4. **Performance Optimization**:
   - Minimize deep UI hierarchies
   - Limit excessive instances
   - Use efficient tweening
   - Implement throttling for frequent updates
5. **Responsive Design**: Adapt to different screen sizes and orientations
6. **Accessibility**: Consider color contrast and text sizing

## Implementation Examples

### Creating a Basic Component

```lua
function CoreComponents.CreateSimpleCounter(name, initialValue, parent)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(0, 100, 0, 40)
    container.BackgroundColor3 = COLORS.SECONDARY
    
    -- Apply rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    -- Value text
    local valueText = Instance.new("TextLabel")
    valueText.Name = "Value"
    valueText.Size = UDim2.new(1, 0, 1, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(initialValue)
    valueText.TextColor3 = COLORS.TEXT
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 18
    valueText.Parent = container
    
    -- Return interface
    return {
        instance = container,
        setValue = function(value)
            valueText.Text = tostring(value)
        end,
        getValue = function()
            return tonumber(valueText.Text) or 0
        end
    }
end
```

### Creating a Tab System

```lua
-- Create tab container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = content

-- Create content container
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -50)
contentContainer.Position = UDim2.new(0, 0, 0, 50)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = content

-- Define tab sections
local tab1Content = Instance.new("Frame")
tab1Content.Size = UDim2.new(1, 0, 1, 0)
tab1Content.BackgroundTransparency = 1

local tab2Content = Instance.new("Frame")
tab2Content.Size = UDim2.new(1, 0, 1, 0)
tab2Content.BackgroundTransparency = 1

-- Create tab definitions
local tabDefinitions = {
    {name = "Profile", content = tab1Content, onActivated = function() print("Profile tab activated") end},
    {name = "Settings", content = tab2Content, onActivated = function() print("Settings tab activated") end}
}

-- Create the tab system
local tabSystem = BaseUI.CreateTabSystem(tabContainer, contentContainer, tabDefinitions)

-- Later, you can switch tabs programmatically
tabSystem.setActiveTab("Settings")
```

### Creating a Modal with the UI Reference System

```lua
function MyNewModal.Show()
    local modalRefs = ModalBase.CreateBaseModal("My Feature", UDim2.new(0, 600, 0, 400))
    if not modalRefs then return end
    
    -- Store core modal references
    BaseUI.AddRef("modals", "myFeature.modal", modalRefs.modal)
    BaseUI.AddRef("modals", "myFeature.content", modalRefs.content)
    BaseUI.AddRef("modals", "myFeature.screenGui", modalRefs.screenGui)
    
    -- Add section header
    local title = BaseUI.CreateSectionHeader("Title", "My Feature Details")
    title.LayoutOrder = 1
    title.Parent = modalRefs.content
    
    BaseUI.AddRef("modals", "myFeature.title", title)
    
    -- Create grid container for items
    local itemsContainer = Instance.new("Frame")
    itemsContainer.Name = "ItemsContainer"
    itemsContainer.Size = UDim2.new(1, 0, 0, 300)
    itemsContainer.BackgroundTransparency = 1
    itemsContainer.LayoutOrder = 2
    itemsContainer.Parent = modalRefs.content
    
    BaseUI.AddRef("modals", "myFeature.itemsContainer", itemsContainer)
    
    -- Create items
    for i = 1, 10 do
        local itemCard = Instance.new("Frame")
        itemCard.Name = "Item_" .. i
        itemCard.BackgroundColor3 = COLORS.SECONDARY
        itemCard.LayoutOrder = i
        
        -- Apply standard card styling
        BaseUI.ApplyCardStyle(itemCard)
        
        -- Store reference with unique path
        BaseUI.AddRef("modals", "myFeature.items." .. i, itemCard)
        
        itemCard.Parent = itemsContainer
    end
    
    -- Set up actions
    local actionButton = BaseUI.CreateStyledButton("ActionButton", "Perform Action")
    actionButton.Size = UDim2.new(0, 200, 0, 40)
    actionButton.Position = UDim2.new(0.5, -100, 1, -60)
    actionButton.Parent = modalRefs.content
    
    BaseUI.AddRef("modals", "myFeature.actionButton", actionButton)
    
    -- Store button connections for cleanup
    local buttonConnections = {}
    
    -- Set up button action
    buttonConnections[actionButton] = actionButton.MouseButton1Click:Connect(function()
        local itemsContainer = BaseUI.GetRef("modals", "myFeature.itemsContainer")
        if itemsContainer then
            -- Perform action with the container
            print("Action performed on items container")
        end
    end)
    
    -- Clean up when modal is closed
    modalRefs.screenGui.AncestryChanged:Connect(function(_, newParent)
        if not newParent then
            -- Clean up connections
            for _, connection in pairs(buttonConnections) do
                connection:Disconnect()
            end
            buttonConnections = {}
            
            -- Clean up references
            BaseUI.RemoveRef("modals", "myFeature")
        end
    end)
end
```

## Future Improvements

1. **Component Library Documentation**: Visual catalog of all available components
2. **UI Theme System**: Support for multiple visual themes
3. **Animation System**: More sophisticated transition effects
4. **UI State Management**: Centralized state management for complex UIs
5. **UI Testing Framework**: Automated testing for UI components 