# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Testing
```bash
# Run all tests
xcodebuild clean test -scheme App -quiet

# Run tests with detailed output  
xcodebuild clean test -scheme App
```

### Code Formatting
```bash
# Always format Swift code before committing
swiftformat **/*.swift

# IMPORTANT: Always run swiftformat after making any Swift code changes
# This ensures consistent code style across the project
```

### Building
```bash
# Build the main app
xcodebuild build -scheme App

# Build the widget extension
xcodebuild build -scheme Widget
```

## Architecture Overview

This is a SwiftUI iOS application for tax tracking with the following modular structure:

### Core Components
- **CoreTaxTracker** - Shared framework containing business logic and data models
- **TaxTracker** - Main iOS app target with UI views
- **TaxTrackerWidget** - Widget extension for iOS home screen

### Data Architecture
- Uses **SwiftData** for persistence with two main models:
  - `TaxTrackingModel` - Main data container
  - `TaxPaymentPlan` - Payroll configuration (start date, interval)
- Models are configured in `TaxTrackerApp.swift:17-22` with `.modelContainer()`

### Key Business Logic
- **PayrollCalendar** (`CoreTaxTracker/Planing/PayrollCalendar.swift`) - Calculates payroll dates based on start date and interval
- **PayrollCalendarChart** - UI component for visualizing payroll schedule
- **PlanningForm** - UI for configuring tax payment plans

### Project Structure
- **CoreTaxTracker/** - Business logic framework
  - `Model/` - SwiftData models
  - `Planing/` - Payroll calculation logic  
  - `Views/` - Shared UI components
- **TaxTracker/** - Main app
  - Contains SwiftUI views and app entry point
- **TaxTrackerWidget/** - Home screen widget
- **Project/** - Xcode configuration files and test plans

### Testing
- Tests located in `TaxTrackerTests/`
- Uses Xcode's test framework with TestPlan configuration
- PayrollCalendar logic is unit tested in `Planning/PayrollCalendarTests.swift`
