# CYSnackbar
Snackbar on iOS

Usage:

```swift
CYSnackbar.make(text: "This is a snackbar", duration: .short).show() // Show a short snackbar
// Show a snackbar with button
CYSnackbar
	.make(text: "This is a snackbar", duration: .short)
    .action(with: "OK", action: { (sender) in        
    	NSLog("snackbar clicked")
    })
    .show()
// Dismiss Handler get called when the snackbar is automatically dismissed.
CYSnackbar
    .make(text: "this is a snackbar", duration: .long)
    .action(with: "OK", action: { (sender) in
        NSLog("snackbar clicked")
    })
    .dismissHandler {
        NSLog("snackbar dismissed")
    }
    .show()
```



