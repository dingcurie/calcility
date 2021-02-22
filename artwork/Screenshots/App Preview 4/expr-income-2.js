
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().scrollViews()[1].buttons()["( )"].tap();
target.delay(0.5);

target.frontMostApp().mainWindow().scrollViews()[1].buttons()["×"].tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("2").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons()["+"].tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("0").tapWithOptions({tapCount:4});

target.delay(0.5);
target.frontMostApp().mainWindow().scrollViews()[1].buttons()[39].tap();  // Return                                                                                   
