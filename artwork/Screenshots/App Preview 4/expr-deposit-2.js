
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().scrollViews()[1].buttons()[24].tap();  // Delete
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("6").tap();

target.delay(0.5);
target.frontMostApp().mainWindow().scrollViews()[1].buttons()[39].tap();  // Return                                                                                   
