
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(0.75);

target.frontMostApp().mainWindow().buttons()["×"].tap();
target.frontMostApp().mainWindow().buttons()["( )"].tap();
target.delay(0.25);

target.frontMostApp().mainWindow().buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().buttons()["+"].tap();
target.frontMostApp().mainWindow().buttons().firstWithName("5").tap();
target.frontMostApp().mainWindow().buttons()["."].tap();
target.frontMostApp().mainWindow().buttons().firstWithName("0").tap();
target.frontMostApp().mainWindow().buttons()["%"].tap();

target.frontMostApp().mainWindow().buttons()["/"].touchAndHold(1.0);
target.delay(0.5);

target.frontMostApp().mainWindow().buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().buttons().firstWithName("2").tap();

target.tap({x:512, y:320});
target.delay(0.25);

target.frontMostApp().mainWindow().buttons()[35].tap();  // Pow
target.delay(0.25);

target.frontMostApp().mainWindow().buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().buttons().firstWithName("2").tap();
target.frontMostApp().mainWindow().buttons()["×"].tap();
target.frontMostApp().mainWindow().buttons().firstWithName("5").tap();
