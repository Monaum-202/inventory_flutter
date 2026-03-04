# Professional Navigation UI System

This document explains the new professional navigation system for the Rapid Global Inventory app.

## Overview

The app now features a responsive, professional-grade navigation sidebar with:
- ✨ **Material 3** modern design
- 📱 **Mobile-optimized** drawer
- 🖥️ **Desktop-optimized** collapsible sidebar (250px ↔ 80px)
- 🎨 **Professional color palette**: black background, coral red active states
- ⚡ **Smooth animations** for state transitions
- 🎯 **Single-module expansion** logic

## Architecture

### Core Navigation Files

Located in `lib/core/navigation/`:

1. **`navigation_model.dart`**
   - `NavigationModule`: Top-level menu items (Dashboard, Inventory, Reports)
   - `NavigationMenu`: Sub-items under modules
   - `defaultNavigationModules`: Pre-configured module structure

2. **`navigation_provider.dart`** (Riverpod Providers)
   - `expandedModuleProvider`: Track which module is currently open
   - `activeMenuProvider`: Track currently selected menu item
   - `sidebarCollapsedProvider`: Track sidebar collapse state (desktop only)

3. **`nav_constants.dart`**
   - `NavColors`: Black background, #ff5252 active, #ff6b6b hover, white text
   - `NavSizing`: Dimensions (250px/80px widths), border radius (10), icon sizes

4. **`module_item.dart`**
   - `ModuleItem`: Expandable module widget with smooth rotation animation
   - `_MenuItemTile`: Individual menu items with hover/active states

5. **`professional_sidebar.dart`**
   - `ProfessionalNavigationSidebar`: Main responsive component
   - Auto-switches between drawer (mobile <768px) and sidebar (desktop)
   - Animated collapse toggle on desktop

## Mobile vs Desktop Layout

### Mobile (<768px width)
- Full-screen drawer slides in from left
- Drawer closes after menu selection
- Simpler navigation footprint

### Desktop (≥768px width)
- Fixed sidebar on left edge with toggle button
- Sidebar animates between 250px expanded and 80px collapsed
- When collapsed: module icons visible, text labels hidden
- Body content remains visible alongside sidebar

## Adding New Modules

To add a new navigation module:

```dart
// In navigation_model.dart, add to defaultNavigationModules:

NavigationModule(
  id: 'unique_id',
  title: 'Module Title',
  icon: Icons.icon_name,
  menus: [
    NavigationMenu(
      id: 'menu_id',
      title: 'Menu Item',
      icon: Icons.menu_icon,
      route: '/route-path',
    ),
    // Add more menu items...
  ],
),
```

Then in `main.dart`, update `_handleMenuSelection()` to map routes to page indices.

## Color Specifications

```dart
background:      #000000 (Colors.black)
active/selected: #ff5252 (slightly more red)
hover state:     #ff6b6b (coral red)
text:            #FFFFFF (Colors.white)
text secondary:  #B0B0B0 (medium gray)
divider:         #333333 (dark gray)
```

## Interaction Patterns

### Module Expansion
- Click module header to expand/collapse
- Only one module can be expanded at a time
- Smooth rotate animation on chevron icon (↓ ↔ →)

### Menu Selection
- Click menu item to select
- Item highlights with #ff5252 background
- Selection persists until another item is clicked
- Drawer automatically closes on mobile after selection

### Desktop Sidebar Collapse
- Click toggle button (≤ or ≥ chevron) at top of sidebar
- Content animates smoothly (300ms)
- Icon visibility toggles with label text

## Responsive Breakpoint

Mobile/desktop switch happens at **768px width** (tablet breakpoint). Adjust in `ProfessionalNavigationSidebar.build()` if needed.

## State Management (Riverpod)

All navigation state is managed via Riverpod providers for predictability:

```dart
// Get current expanded module
final expanded = ref.watch(expandedModuleProvider); // String? (module id or null)

// Get active menu item
final active = ref.watch(activeMenuProvider); // String? (menu id or null)

// Get collapse state
final collapsed = ref.watch(sidebarCollapsedProvider); // bool
```

Update state:

```dart
ref.read(expandedModuleProvider.notifier).state = 'new_module_id';
ref.read(activeMenuProvider.notifier).state = 'menu_id';
ref.read(sidebarCollapsedProvider.notifier).state = true;
```

## Styling Guidelines

- **Border radius**: All interactive items use `BorderRadius.circular(10)`
- **Icon sizes**: Module icons = 24px, Menu icons = 20px
- **Spacing**: Modules/menus have 12px horizontal margins
- **Animations**: All transitions are 300ms smooth curves
- **Hover effects**: Transparent color overlay (15-20% opacity)
- **Typography**: 
  - Module titles: 14px, medium weight
  - Menu items: 13px, regular (active = bold)

## Future Enhancements

- [ ] Persist sidebar collapse state to local storage
- [ ] Add "favorites" feature to pin frequently used menus
- [ ] Support drag-reorder modules
- [ ] Add breadcrumb navigation
- [ ] Support permission-based module visibility
