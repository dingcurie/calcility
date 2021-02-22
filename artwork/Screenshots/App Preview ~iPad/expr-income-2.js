
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().buttons()["( )"].tap();
target.delay(0.5);

target.frontMostApp().mainWindow().buttons()["×"].tap();
target.frontMostApp().mainWindow().buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().buttons().firstWithName("2").tap();
target.frontMostApp().mainWindow().buttons()["+"].tap();
target.frontMostApp().mainWindow().buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().buttons().firstWithName("0").tapWithOptions({tapCount:4});

target.delay(0.5);
target.frontMostApp().mainWindow().buttons()[41].tap();  // Return
