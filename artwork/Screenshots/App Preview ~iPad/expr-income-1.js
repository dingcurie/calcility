
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().buttons().firstWithName("8").tap();
target.frontMostApp().mainWindow().buttons().firstWithName("0").tapWithOptions({tapCount:3});
target.frontMostApp().mainWindow().buttons()["−"].tap();
target.frontMostApp().mainWindow().buttons().firstWithName("5").tap();
target.frontMostApp().mainWindow().buttons().firstWithName("0").doubleTap();

