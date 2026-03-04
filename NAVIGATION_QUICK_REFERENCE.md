# Navigation System Quick Reference

## File Structure

```
lib/core/navigation/
├── navigation_model.dart        # Data models (NavigationModule, NavigationMenu)
├── navigation_provider.dart     # Riverpod state providers (expandedModule, activeMenu, sidebarCollapsed)
├── nav_constants.dart           # Design constants (colors, dimensions, animations)
├── module_item.dart             # Expandable module + menu item widgets
├── professional_sidebar.dart    # Responsive sidebar/drawer wrapper
```

## Key Components

### 1. Navigation Model (`navigation_model.dart`)

```dart
NavigationModule(
  id: 'dashboard',
  title: 'Dashboard',
  icon: Icons.dashboard,
  menus: [
    NavigationMenu(id: 'view', title: 'View', icon: Icons.bar_chart, route: '/dashboard'),
    NavigationMenu(id: 'analytics', title: 'Analytics', icon: Icons.analytics, route: '/analytics'),
  ],
)
```

### 2. State Providers (`navigation_provider.dart`)

```dart
// Watch which module is currently expanded
ref.watch(expandedModuleProvider);  // String? (module id or null)

// Watch which menu is active
ref.watch(activeMenuProvider);      // String? (menu id or null)

// Watch sidebar collapse state (desktop only)
ref.watch(sidebarCollapsedProvider); // bool
```

### 3. Design Constants (`nav_constants.dart`)

```dart
NavColors.background       // #000000
NavColors.activeBackground // #ff5252 (selected)
NavColors.activeHover      // #ff6b6b (hover)
NavColors.text             // #FFFFFF
NavColors.textSecondary    // #B0B0B0
NavColors.divider          // #333333

NavSizing.sidebarExpandedWidth   // 250px
NavSizing.sidebarCollapsedWidth  // 80px
NavSizing.borderRadius           // 10px
NavSizing.animationDuration      // 300ms
```

## Usage in main.dart

### Mobile Layout (<768px)
```dart
Scaffold(
  drawer: ProfessionalNavigationSidebar(
    modules: defaultNavigationModules,
    onMenuSelected: (menu) {
      Navigator.pop(context);
      // Handle menu selection
    },
  ),
  body: currentPage,
)
```

### Desktop Layout (≥768px)
```dart
Row(
  children: [
    ProfessionalNavigationSidebar(
      modules: defaultNavigationModules,
      onMenuSelected: (menu) => handleMenuSelection(menu),
    ),
    Expanded(child: currentPage),
  ],
)
```

## Behavior

### Module Expansion
- **Click** module header to expand/collapse
- **Constraint**: Only one module open at a time
- **Animation**: Smooth 300ms transition with chevron rotation (↓ ↔ →)

### Menu Selection
- **Click** menu item to select
- **Highlight**: #ff5252 background when active
- **Callback**: `onMenuSelected` fires with selected `NavigationMenu`

### Sidebar Collapse (Desktop Only)
- **Toggle** button at sidebar top
- **Animation**: 250px ↔ 80px smooth expansion
- **State**: Tracked by `sidebarCollapsedProvider`
- When collapsed: icons visible, labels hidden

## Adding New Modules

1. **Update** `navigation_model.dart`:
```dart
defaultNavigationModules = [
  // ... existing modules ...
  NavigationModule(
    id: 'settings',
    title: 'Settings',
    icon: Icons.settings,
    menus: [
      NavigationMenu(id: 'profile', title: 'Profile', icon: Icons.person, route: '/settings/profile'),
      NavigationMenu(id: 'preferences', title: 'Preferences', icon: Icons.tune, route: '/settings/prefs'),
    ],
  ),
];
```

2. **Update** `main.dart` `_handleMenuSelection()`:
```dart
case '/settings/profile':
case '/settings/prefs':
  ref.read(pageIndexProvider.notifier).state = 3; // New page index
  break;
```

3. **Create** new page in corresponding feature folder

## Styling Flexibility

All styling is centralized in `nav_constants.dart`:
- **Change colors**: Update `NavColors` class
- **Adjust sizes**: Modify `NavSizing` class
- **Tweak animation**: Change `animationDuration`

Benefits:
- ✅ Single source of truth for styling
- ✅ Easy global redesigns
- ✅ Consistent across all components
- ✅ No scattered magic numbers

## Performance Notes

- **Widget rebuilds**: Only affected components rebuild when state changes
- **State scope**: Navigation state is lightweight (3 `StateProvider`s)
- **Memory**: Module list is immutable and reused across rebuilds
- **Animations**: GPU-accelerated via `AnimatedContainer`

## Testing Navigation

```bash
# Test on different screen sizes
flutter run -d <device-id>

# Check responsive breakpoint (<768px = mobile, ≥768px = desktop)
# Use DevTools to simulate different screen sizes
```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Module doesn't collapse | Child didn't update | Call `ref.read(...notifier).state = null` |
| Drawer won't close | `Navigator.pop(context)` missing | Add to `onMenuSelected` callback |
| Sidebar doesn't animate | Wrong widget type | Ensure using `AnimatedContainer` |
| Colors look wrong | Cache issue | Run `flutter clean && flutter pub get` |

## Future Enhancements

- [ ] Persist expanded/collapsed state to `SharedPreferences`
- [ ] Add breadcrumb navigation above content
- [ ] Support module drag-reordering
- [ ] Permission-based module visibility
- [ ] Search across all menu items
- [ ] Save favorite menus (pin feature)
