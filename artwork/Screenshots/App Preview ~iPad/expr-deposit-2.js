
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().buttons()[11].tap();
target.frontMostApp().mainWindow().buttons().firstWithName("6").tap();

target.delay(0.5);
target.frontMostApp().mainWindow().buttons()[41].tap();
