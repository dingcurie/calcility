
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(0.5);

target.frontMostApp().mainWindow().scrollViews()[1].buttons()["×"].tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons()["( )"].tap();
target.delay(0.25);

target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons()["+"].tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("5").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons()["."].tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("0").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons()["%"].tap();

target.frontMostApp().mainWindow().scrollViews()[1].buttons()["/"].touchAndHold(0.75);
target.delay(0.25);

target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("2").tap();

target.tap({x:300, y:250});
target.delay(0.25);

target.flickFromTo({x:20, y:460}, {x:300, y:460});
target.delay(0.5);
target.frontMostApp().mainWindow().scrollViews()[1].buttons()[18].tap();  //Pow
target.delay(0.25);

target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("1").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("2").tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons()["×"].tap();
target.frontMostApp().mainWindow().scrollViews()[1].buttons().firstWithName("5").tap();

