
var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().tableViews()[0].cells()[0].touchAndHold(1.0);
target.frontMostApp().editingMenu().elements()["Annotate"].tapWithOptions({duration:0.5});
target.frontMostApp().keyboard().typeString("Income");

target.delay(0.5);

target.frontMostApp().mainWindow().tableViews()[0].cells()[1].tap();
target.frontMostApp().keyboard().typeString("Deposit");
