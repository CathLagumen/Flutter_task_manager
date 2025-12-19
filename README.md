# Task Manager - Flutter Mobile Application

A task management app built with Flutter that supports full CRUD operations using the JSONPlaceholder API, with offline access and local data storage.

## Features Implemented

### Core Features
-  **CRUD Operations**
  - Fetch all tasks from API
  - View single task details
  - Create new tasks
  - Update task completion status
  - Delete tasks
  - Edit task titles

- **Task List (Home Screen)**
  - Display tasks with title, completion status, and user ID
  - Pull-to-refresh functionality
  - Loading indicators
  - Error handling with retry option
  - Filter by completion status (All/Completed/Pending)
  - Search tasks by title
  - Floating action button to add tasks

- **Task Detail Screen**
  - Display full task information
  - Shows Task ID, User ID, Title, Status, Created Date
  - Uses FutureBuilder for async data loading
  - Error and loading states
  - Back button navigation

- **Task Form Screen**
  - Create new tasks with validation
  - Title field (required, minimum 3 characters)
  - User ID field (required, must be numeric)
  - Completion status toggle
  - Form validation with error messages
  - Save and Cancel buttons

- **Settings Screen**
  - Dark mode toggle (persisted)
  - Grid/List view toggle (persisted)
  - Clear cache functionality
  - App information

### Advanced Features
- **Local Data Persistence**
  - Cache API responses using SharedPreferences
  - Save user preferences (theme, view mode)
  - Show cached data when offline
  - Display offline indicator with last update time

- **View Modes**
  - List view with swipe-to-delete
  - Grid view with 2-column layout
  - Toggle between views (AppBar & Settings)
  - View preference persists across sessions

- **User Experience**
  - Dark mode support
  - Optimistic UI updates
  - Success/error snackbars
  - Confirmation dialogs before destructive actions
  - Swipe to delete in list view
  - Real-time search filtering

- **State Management**
  - Provider pattern for global state
  - Separate providers for tasks, theme, and view mode
  - Efficient rebuilds with Consumer widgets

## API Endpoints Used
- **JSONPlaceholder**
  - Base URL: `https://jsonplaceholder.typicode.com`
  - Get all tasks(GET)
      GET https://jsonplaceholder.typicode.com/todos
  - Get single task(GET)    
      GET https://jsonplaceholder.typicode.com/{id}
  - Create Post(POST)
      POST https://jsonplaceholder.typicode.com/todos
      Body: {
        "userId": 1,
        "title": "New task",
        "completed": false
      }    

**Note:** JSONPlaceholder is a fake API, so POST/PUT/DELETE won't persist on the server, but returns successful responses for local UI updates.

## Technologies Used

### Framework & Language
- **Flutter** - UI framework
- **Dart** - Programming language

### Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                   
  provider: ^6.1.5                
  shared_preferences: ^2.2.2      
```


## Project Structure
```
lib/
├── main.dart                          
├── models/
│   └── task.dart                      
├── services/
│   ├── api_service.dart               
│   └── cache_service.dart             
├── providers/
│   ├── task_provider.dart             
│   ├── theme_provider.dart            
│   └── view_mode_provider.dart       
├── screens/
│   ├── home_screen.dart               
│   ├── task_detail_screen.dart        
│   ├── task_form_screen.dart          
│   └── settings_screen.dart           
├── widgets/
│   ├── task_card.dart                 
│   └── task_list.dart                 
└── utils/
    ├── app_theme.dart                 
    ├── theme_provider.dart            
    └── constants.dart                 
```


## How to Run

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation Steps

1. **Clone the repository**
```bash
   git clone <your-repo-url>
   cd task_manager
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Run the app**
```bash
   flutter run
```

4. **Build APK (optional)**
```bash
   flutter build apk --release
```

## Screenshots
 - Home screen with task list(list view)
   <img width="167" height="385" alt="image" src="https://github.com/user-attachments/assets/b6b499ab-1df4-463c-8e8b-b4959a003da7" />


 - Home screen with grid view
   <img width="167" height="386" alt="image" src="https://github.com/user-attachments/assets/f2c45cbf-71cc-49c5-891a-7bfdce93ff9e" />

   

 - Task detail screen
   <img width="167" height="388" alt="image" src="https://github.com/user-attachments/assets/24a7e34c-4310-462d-bde3-db9d701101f0" />


 - Add new task form
  <img width="166" height="387" alt="image" src="https://github.com/user-attachments/assets/ce9378c3-bfb6-485c-aaf4-3a0d7babddea" />
 

 - Settings screen
   <img width="167" height="387" alt="image" src="https://github.com/user-attachments/assets/f14ab807-6187-4c8d-af59-80cb9d061f43" />


 - Offline mode indicator
  <img width="166" height="388" alt="image" src="https://github.com/user-attachments/assets/d6493739-781e-4952-9759-5fa90c9b0f8a" />


 - Error state with retry button
  <img width="164" height="386" alt="image" src="https://github.com/user-attachments/assets/56785361-4503-474f-860f-7c9d001f9360" />


 - Different filter states(All/Completed/Pending)
   <img width="170" height="109" alt="image" src="https://github.com/user-attachments/assets/d782d905-c84f-4592-91cf-7dd13fabdaf6" />



### Light Mode
- Home Screen (List View)
- Home Screen (Grid View)
- Task Details
- Add Task Form
- Settings

### Dark Mode
- Home Screen (List View)
- Home Screen (Grid View)
- Task Details
- Add Task Form
- Settings

### Offline Mode
- Cached data indicator
- Error handling

## Implementation Checklist

### Required Features
- Get all tasks (GET)
- Get single task (GET)
- Create task (POST)
- Task list with ListView.builder
- Pull-to-refresh functionality
- Loading indicator
- Error handling with retry
- Filter by completion status
- Task detail screen
- Add task screen with validation
- Settings screen
- Dark mode toggle (persisted)
- Local data caching
- Offline mode support
- Cache indicator

### Technical Requirements
- HTTP requests with timeout (10s)
- JSON parsing (fromJson/toJson)
- Error handling (try-catch)
- FutureBuilder for async operations
- Proper state management
- SharedPreferences for persistence
- Clean project structure
- Reusable widgets


