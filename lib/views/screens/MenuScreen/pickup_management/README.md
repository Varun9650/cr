# Pickup Management System

## Overview
The Pickup Management System is a comprehensive solution for managing pickup records, payment tracking, certificate distribution, and t-shirt delivery. It follows the MVVM (Model-View-ViewModel) architecture pattern and provides a modern, production-level UI.

## Features

### 1. User Management
- Dropdown selection of all users from the system
- User information display and tracking

### 2. Pickup Address Management
- **Map Integration**: Choose pickup location using map coordinates
- **Manual Entry**: Enter pickup address manually
- Address validation and storage

### 3. Status Tracking
- **Pickup Completed**: Track if pickup has been completed
- **Payment Completed**: Track payment status
- **Certificate Received**: Track certificate distribution
- **T-Shirt Received**: Track t-shirt delivery

### 4. Search and Filter
- Search by user name or address
- Real-time filtering of records
- Pagination support for large datasets

### 5. Statistics Dashboard
- Total pickup records
- Completed pickups
- Pending payments
- Pending certificates

## Architecture

### MVVM Structure
```
Pickup_Management/
├── model/
│   └── pickup_management_model.dart
├── repository/
│   └── pickup_management_api_service.dart
├── viewmodel/
│   └── pickup_management_viewmodel.dart
└── views/
    ├── pickup_management_screen.dart
    ├── pickup_form_screen.dart
    └── pickup_detail_screen.dart
```

### Components

#### Model (`pickup_management_model.dart`)
- Data structure for pickup records
- Form data management
- Status tracking properties
- Location coordinates storage

#### Repository (`pickup_management_api_service.dart`)
- API service for CRUD operations
- Network communication
- Error handling
- Data transformation

#### ViewModel (`pickup_management_viewmodel.dart`)
- Business logic implementation
- State management
- Data binding
- User interactions

#### Views
- **Main Screen**: List view with search and statistics
- **Form Screen**: Add new pickup records
- **Detail Screen**: View and edit existing records

## API Endpoints

The system uses the following API endpoints:

- `GET /Pickup_Management/Pickup_Management` - Get all pickup records
- `GET /Pickup_Management/Pickup_Management/getall/page` - Get paginated records
- `POST /Pickup_Management/Pickup_Management` - Create new pickup record
- `PUT /Pickup_Management/Pickup_Management/{id}` - Update pickup record
- `DELETE /Pickup_Management/Pickup_Management/{id}` - Delete pickup record
- `GET /api/getuser/accountid` - Get users for dropdown
- `PUT /Pickup_Management/Pickup_Management/status/{id}` - Update status

## Usage

### Adding a New Pickup Record
1. Navigate to the Pickup Management screen
2. Tap the floating action button (+)
3. Select a user from the dropdown
4. Choose pickup address (map or manual entry)
5. Set status toggles as needed
6. Save the record

### Editing an Existing Record
1. Tap on any pickup record card
2. View detailed information
3. Tap the edit button (pencil icon)
4. Modify status toggles
5. Save changes

### Searching Records
1. Use the search bar at the top
2. Type user name or address
3. Results filter in real-time

## Data Structure

### Pickup Record
```json
{
  "id": 1,
  "userId": 123,
  "userName": "John Doe",
  "pickupAddress": "123 Main Street, City, State",
  "pickupLatitude": 40.7128,
  "pickupLongitude": -74.0060,
  "isPickupCompleted": false,
  "isPaymentCompleted": false,
  "isCertificateReceived": false,
  "isTshirtReceived": false,
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:00Z"
}
```

## Dependencies

- `provider`: State management
- `flutter`: Core framework
- `http`: Network requests (via existing network service)

## Future Enhancements

1. **Real Map Integration**: Integrate with Google Maps or OpenStreetMap
2. **Push Notifications**: Notify users about status changes
3. **Bulk Operations**: Select multiple records for batch updates
4. **Export Functionality**: Export data to CSV/PDF
5. **Advanced Filtering**: Filter by date range, status combinations
6. **Offline Support**: Cache data for offline access

## Installation

1. Ensure all dependencies are added to `pubspec.yaml`
2. Import the pickup management entry point
3. Navigate to `PickupManagementEntry()` widget
4. Configure API endpoints in `api_constants.dart`

## Contributing

When contributing to this system:
1. Follow the existing MVVM pattern
2. Maintain consistent styling
3. Add proper error handling
4. Include unit tests for new features
5. Update documentation as needed 