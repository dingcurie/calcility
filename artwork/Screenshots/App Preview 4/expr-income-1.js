
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("8").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("0").tapWithOptions({tapCount:3});
target.frontMostApp().mainWindow().scrollViews()[1].buttons()["−"].tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("5").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("0").doubleTap();
