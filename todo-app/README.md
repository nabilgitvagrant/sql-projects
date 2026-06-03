# To-Do List Application

A modern, feature-rich to-do list application with local storage functionality. Perfect for managing tasks and staying organized.

## 🌟 Features

### Task Management
- ✅ **Add Tasks** - Create new tasks with character limit (100 chars)
- ✏️ **Edit Tasks** - Double-click or click edit button to modify tasks
- 🗑️ **Delete Tasks** - Remove individual tasks with confirmation
- ✓ **Mark Complete** - Toggle task completion status
- 🔍 **Search & Filter** - Filter by All, Active, or Completed tasks

### Smart Organization
- 📅 **Date Tracking** - Automatic timestamp for each task
- 🔤 **Sort by Name** - Alphabetical task sorting
- 🔢 **Sort by Date** - Newest first sorting
- 📊 **Progress Tracking** - Visual progress bar and statistics
- 💾 **Auto-Save** - Tasks automatically saved to local storage

### Statistics & Analytics
- 📈 **Total Tasks** - Count of all tasks
- ✅ **Completed Tasks** - Count of finished tasks
- 📊 **Progress Percentage** - Visual completion progress
- 🎯 **Task Counters** - Count by filter (All/Active/Completed)

### Bulk Operations
- 🧹 **Clear Completed** - Remove all completed tasks at once
- ⚠️ **Clear All** - Delete all tasks (with confirmation)
- 💾 **Local Storage** - Persistent data across browser sessions

### User Experience
- 🎨 **Beautiful UI** - Modern gradient design
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile
- ⌨️ **Keyboard Support** - Enter to add, Escape to cancel
- 🎯 **Character Counter** - Live character count display
- 🌙 **Dark Mode Support** - Automatic dark mode detection

## 📂 File Structure

```
todo-app/
├── index.html       # HTML structure
├── styles.css       # CSS styling (650+ lines)
├── script.js        # JavaScript functionality
└── README.md        # Documentation
```

## 🚀 Getting Started

### Installation
1. Clone or download the repository
2. Open `index.html` in your web browser
3. Start adding tasks!

### Usage

#### Adding a Task
1. Type your task in the input field
2. Click "Add" button or press Enter
3. Task appears at the top of the list

#### Editing a Task
- **Method 1**: Double-click the task text
- **Method 2**: Click the ✏️ edit button
- Press Enter to save or Escape to cancel

#### Completing a Task
- Check the checkbox next to the task
- Task will be marked with strikethrough
- It will appear in the "Completed" filter

#### Deleting a Task
- Click the 🗑️ delete button
- Confirm the deletion
- Task is removed permanently

#### Filtering Tasks
- Click filter buttons: "All", "Active", "Completed"
- View counts update automatically
- List filters in real-time

#### Sorting Tasks
- Click "🔢 Date" to sort by creation date (newest first)
- Click "🔤 Name" to sort alphabetically
- Sort preference is maintained while filtering

#### Managing Multiple Tasks
- **Clear Completed**: Removes all finished tasks
- **Clear All**: Removes every task (requires confirmation)

## 💾 Local Storage

### How It Works
- All tasks are automatically saved to browser's local storage
- Data persists across browser sessions and page refreshes
- No server or internet connection required
- Storage limit: ~5-10MB per domain

### Data Structure
```json
{
  "id": 1717420800000,
  "text": "Buy groceries",
  "completed": false,
  "createdAt": "6/3/2026, 8:00:00 PM",
  "updatedAt": "6/3/2026, 8:00:00 PM"
}
```

### Viewing Stored Data
Open browser console (F12) and run:
```javascript
console.log(JSON.parse(localStorage.getItem('todos')));
```

### Clearing Local Storage
```javascript
localStorage.removeItem('todos');
```

## 🎨 Customization

### Change Primary Color
Edit the CSS variables in `styles.css`:
```css
:root {
    --primary-color: #667eea;  /* Change this color */
    --secondary-color: #764ba2;
}
```

### Adjust Character Limit
In `script.js`, find the `addTodo()` method:
```javascript
if (text.length > 100) {  // Change 100 to desired limit
    alert('Task must be 100 characters or less');
}
```

### Add New Filters
Extend the filter functionality by modifying the `getFilteredAndSortedTodos()` method.

## 📱 Responsive Design

- **Desktop**: Full features with side-by-side controls
- **Tablet**: Optimized layout for touch interaction
- **Mobile**: Stacked layout, touch-friendly buttons
- **Accessibility**: Works with keyboard navigation and screen readers

## 🔒 Security

- XSS Protection: All user input is escaped using `escapeHtml()`
- No external dependencies
- No network requests
- All data stored locally on your device
- No tracking or analytics

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Enter | Add task or save edit |
| Escape | Cancel editing |
| Tab | Navigate between elements |
| Double-click | Edit task |

## 🌙 Dark Mode

The app automatically respects your system's color scheme preference:
- Uses `prefers-color-scheme: dark` media query
- Automatically switches to dark mode if system preference is set
- No toggle needed - system preference is respected

## 🐛 Troubleshooting

### Tasks Not Saving
**Issue**: Tasks disappear after refresh
**Solution**: Check if local storage is enabled in browser settings

### Tasks Not Appearing
**Issue**: Empty list after adding tasks
**Solution**: Clear browser cache and reload the page

### Edit Not Working
**Issue**: Can't edit tasks
**Solution**: Make sure JavaScript is enabled in your browser

## 📊 Browser Compatibility

| Browser | Support |
|---------|---------|
| Chrome | ✅ Full |
| Firefox | ✅ Full |
| Safari | ✅ Full |
| Edge | ✅ Full |
| IE 11 | ⚠️ Limited |

## 🚀 Future Enhancements

Potential features for future versions:
- [ ] Drag-and-drop reordering
- [ ] Task categories/tags
- [ ] Priority levels
- [ ] Due dates with reminders
- [ ] Recurring tasks
- [ ] Cloud sync
- [ ] Multiple lists
- [ ] Notes/descriptions per task
- [ ] Time tracking
- [ ] Task sharing

## 📝 Tips & Tricks

1. **Bulk Operations**: Use "Clear Completed" regularly to keep your list clean
2. **Character Limit**: Keep tasks concise and actionable
3. **Organization**: Use consistent naming for related tasks
4. **Sorting**: Switch between Date and Name sorting based on your needs
5. **Browser Storage**: Your data is never sent to any server - it's 100% private

## 📄 License

MIT License - Free to use and modify

## 👤 Author

**Nabil** - [GitHub Profile](https://github.com/nabilgitvagrant)

## 💬 Feedback

Have suggestions or found issues? Feel free to contribute or report!

---

## 📊 Statistics

- **HTML Lines**: ~120
- **CSS Lines**: ~650
- **JavaScript Lines**: ~450
- **Total**: ~1,200 lines of code
- **Dependencies**: None (Vanilla JavaScript)
- **File Size**: ~45KB (minified: ~15KB)

---

**Enjoy organizing your tasks! 📝✨**

*Last Updated: 2026-06-03*
